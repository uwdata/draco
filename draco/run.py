'''
Run constraint solver to complete spec.
'''

import json
import logging
import os
import subprocess
from typing import Dict, List

import clyngor

from draco.spec import Query, Task

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DRACO_LP = ['define.lp', 'generate.lp', 'test.lp', 'features.lp', 'weights.lp', 'assign_weights.lp', 'optimize.lp', 'output.lp']
DRACO_LP_DIR = os.path.join(os.path.dirname(__file__), '../asp')


def run(task: Task, constants: Dict[str, str] = None, files: List[str] = None, silence_warnings=False) -> Task:
    ''' Run clingo to compute a completion of a partial spec or violations.
    '''

    # default args
    files = files or DRACO_LP
    constants = constants or {}

    run_command = clyngor.command(
        files=[os.path.join(DRACO_LP_DIR, f) for f in files],
        inline=task.to_asp(),
        constants=constants,
        stats=False,
        options=['--outf=2'] + (['--warn=no-atom-undefined'] if silence_warnings else []))

    logger.info('Command: %s', ' '.join(run_command))

    clingo = subprocess.run(run_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    stderr = clingo.stderr.decode('utf-8')
    stdout = clingo.stdout.decode('utf-8')

    try:
        json_result = json.loads(stdout)
    except json.JSONDecodeError:
        logger.error('stdout: %s', stdout)
        logger.error('stderr: %s', stderr)
        raise

    violations: Dict[str, int] = {}
    if stderr:
        try:
            violations = json.loads(stderr)
        except json.JSONDecodeError:
            logger.error(stderr)

    result = json_result['Result']

    if result == 'UNSATISFIABLE':
        logger.info('Constraints are unsatisfiable.')
        return None
    elif result == 'OPTIMUM FOUND':
        # get the last witness, which is the best result
        answers = json_result['Call'][0]['Witnesses'][-1]

        logger.info(answers['Value'])

        query = Query.parse_from_answer(clyngor.Answers(answers['Value']).sorted)
        return Task(task.data, query, answers['Costs'][0], violations)
    elif result == 'SATISFIABLE':
        answers = json_result['Call'][0]['Witnesses'][-1]

        logger.info(answers['Value'])

        query = Query.parse_from_answer(clyngor.Answers(answers['Value']).sorted)
        return Task(task.data, query, violations=violations)
    else:
        logger.error('Unsupported result: %s', result)
        return None
