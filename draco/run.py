'''
Run constraint solver to complete spec.
'''

import json
import logging
import os
import subprocess
import tempfile
from typing import Dict, List, Tuple, Optional

import clyngor

from draco.spec import Query, Task

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DRACO_LP = ['define.lp', 'generate.lp', 'hard.lp', 'soft.lp', 'weights.lp', 'assign_weights.lp', 'optimize.lp', 'output.lp']
DRACO_LP_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../asp'))


file_cache: Dict = {}

def load_file(path):
    content =  file_cache.get(path)
    if content is not None:
        return content
    with open(path) as f:
        content = f.read().encode('utf8')
        file_cache[path] = content
        return content

def run_draco(task: Task, constants: Dict[str, str] = None, files: List[str] = None, silence_warnings=False, debug=False) -> Tuple[str, str]:
    '''
    Run draco and return stderr and stdout
    '''

    # default args
    files = files or DRACO_LP
    constants = constants or {}

    options = ['--outf=2', '--quiet=1,2,2']
    if silence_warnings:
        options.append('--warn=no-atom-undefined')
    for name, value in constants.items():
        options.append(f'-c {name}={value}')

    cmd = ['clingo'] + options
    logger.debug('Command: %s', ' '.join(cmd))

    proc = subprocess.Popen(
        args=cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)

    task_program = task.to_asp()
    file_names = [os.path.join(DRACO_LP_DIR, f) for f in files]
    asp_program = b'\n'.join(map(load_file, file_names)) + task_program.encode('utf8')

    if debug:
        with tempfile.NamedTemporaryFile(mode='w', delete=False) as fd:
            fd.write(task_program)

            logger.info('Debug ASP with "clingo %s %s"', ' '.join(file_names), fd.name)

    stdout, stderr = proc.communicate(asp_program)

    return (stderr, stdout)

def run(task: Task, constants: Dict[str, str] = None, files: List[str] = None, silence_warnings=False, debug=False, clear_cache=False) -> Optional[Task]:
    ''' Run clingo to compute a completion of a partial spec or violations. '''

    # Clear file cache. useful during development in notebooks.
    if clear_cache and file_cache:
        logger.warning('Cleared file cache')
        file_cache.clear()

    stderr, stdout = run_draco(task, constants, files, silence_warnings, debug)

    try:
        json_result = json.loads(stdout)
    except json.JSONDecodeError:
        logger.error('stdout: %s', stdout)
        logger.error('stderr: %s', stderr)
        raise

    if stderr:
        logger.error(stderr)

    result = json_result['Result']

    if result == 'UNSATISFIABLE':
        logger.info('Constraints are unsatisfiable.')
        return None
    elif result == 'OPTIMUM FOUND':
        # get the last witness, which is the best result
        answers = json_result['Call'][0]['Witnesses'][-1]

        logger.debug(answers['Value'])

        return Task.parse_from_answer(
            clyngor.Answers(answers['Value']).sorted,
            data=task.data,
            cost=json_result['Models']['Costs'][0])
    elif result == 'SATISFIABLE':
        answers = json_result['Call'][0]['Witnesses'][-1]

        assert json_result['Models']['Number'] == 1, 'Should not have more than one model if we don\'t optimize'

        logger.debug(answers['Value'])

        return Task.parse_from_answer(
            clyngor.Answers(answers['Value']).sorted,
            data=task.data)
    else:
        logger.error('Unsupported result: %s', result)
        return None
