import subprocess
import os
import json
from draco.spec import Query, Task

import logging

logger = logging.getLogger(__name__)

DATA_FIELD_TYPES = ['string', 'string', 'string', 'number', 'string',
                    'number', 'string', 'number', 'number', 'number',
                    'number', 'number', 'number', 'string', 'number',
                    'number', 'number', 'number', 'string', 'number',
                    'string', 'number', 'datetime', 'number', 'string']

NUM_FIELDS = [5, 10, 15, 20, 25]
NUM_ENCODINGS = [1, 2, 3, 4, 5]
NUM_TRIALS = 20

CLINGO_PREFIX = 'clingo asp/_all.lp '
CLINGO_OPTIONS = '--quiet=1 --warn=no-atom-undefined -c max_extra_encs=0'

DRACO_LP_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../asp'))
DRACO_LP = ['define.lp', 'generate.lp', 'hard.lp', 'soft.lp', 'weights.lp', 'assign_weights.lp', 'optimize.lp', 'output.lp']

def main():
    # warmup
    logger.info('warming up...')
    run_set()

    # actual
    results = []
    run_set(results)

    with open('draco_runtimes.json', 'w') as out:
        json.dump(results, out, indent=2)

def run_set(results = None):
    for nfields in NUM_FIELDS:
        for nencodings in NUM_ENCODINGS:
            query = generate_asp_query(nfields, nencodings)

            total_time = 0
            for _ in range(NUM_TRIALS):
                asp_query = generate_asp_query(nfields, nencodings)
                total_time += run(asp_query)

            avg_time = total_time / NUM_TRIALS

            if (results is not None):
                results.append({
                    'fields': nfields,
                    'encodings': nencodings,
                    'runtime': avg_time,
                    'system': 'draco'
                })

                logger.info('running fields={0} encodings={1} query time: {2}'.format(nfields, nencodings, avg_time))

def run(asp_query):
    # default args
    options = ['--outf=2', '--quiet=3', '--warn=no-atom-undefined', '-c', 'max_extra_encs=0']

    cmd = ['clingo'] + options

    proc = subprocess.Popen(
        args=cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)

    file_names = [os.path.join(DRACO_LP_DIR, f) for f in DRACO_LP]
    asp_program = b'\n'.join(map(load_file, file_names)) + asp_query.encode('utf8')

    stdout, stderr = proc.communicate(asp_program)

    out = json.loads(stdout)
    return out['Time']['CPU']

def load_file(path):
    with open(path) as f:
        content = f.read().encode('utf8')
        return content

def generate_asp_query(nfields, nencodings):
    query_string = ''

    for i in range(nfields):
        field_name = chr(ord('a') + i)
        field_def = 'fieldtype({0},{1}).\n'.format(field_name, DATA_FIELD_TYPES[i])
        query_string += field_def

    for i in range(nencodings):
        encoding_name = 'e{0}'.format(i)
        encoding_def = 'encoding({0}).\n'.format(encoding_name)
        query_string += encoding_def

    return query_string


if __name__ == '__main__':
    main()
