#!/usr/bin/env python3

import sys
import argparse
import logging
import io
import json
import os

from draco.run import run
from draco.spec import Task, AspTask
from draco import __version__
from enum import Enum

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ArgEnum(Enum):
    def __str__(self):
        return self.value

    @staticmethod
    def from_string(s):
        try:
            return QueryType[s]
        except KeyError:
            raise ValueError()

class QueryType(ArgEnum):
    draco = 'draco'
    cql = 'cql'
    vl = 'vl'
    asp = 'asp'


class Mode(ArgEnum):
    optimize = 'optimize'
    violations = 'violations'
    valid = 'valid'


def create_parser():
    parser = argparse.ArgumentParser(description='Draco Visualization recommendation system.',
        epilog='There is a moment in every dawn when light floats, there is the possibility of magic. Creation holds its breath. — Douglas Adams, The Hitchhikers Guide to the Galaxy')

    parser.add_argument('query', nargs='?', type=argparse.FileType('r'), default=sys.stdin,
                        help='The input query.')
    parser.add_argument('--type', '-t', type=QueryType, choices=list(QueryType), default=QueryType.draco,
                        help='Type of query. draco (Draco, default), cql (CompassQl), vl (Vega-Lite), asp (Answer Set Program).')
    parser.add_argument('--mode', '-m', type=Mode, choices=list(Mode), default=Mode.optimize,
                        help='Mode to run draco in.',)
    parser.add_argument('--out', '-o', type=argparse.FileType('w'), default=sys.stdout,
                        help='specify the Vega-Lite output file')
    parser.add_argument('--base', '-b', default=None, help='Base directory.')
    parser.add_argument('--debug', '-d', help='Create debugging information.', action='store_true')
    parser.add_argument('--version', action='version',
                        version=__version__)

    return parser


def main():  # pragma: no cover
    parser = create_parser()
    args = parser.parse_args()

    if args.mode != Mode.optimize and (args.type == QueryType.draco or args.type == QueryType.cql):
        print('Validation only works with full specs.', sys.stderr)
    else:
        logger.info(f'Processing query: {args.query.name} ...')

        if args.type == QueryType.asp:
            input_task = AspTask(args.query.read())
        else:
            # load a task from a spec provided by the user
            query_spec = json.load(args.query)
            d = args.base or os.path.dirname(args.query.name)
            if args.type == QueryType.draco:
                input_task = Task.from_obj(query_spec, d)
            elif args.type == QueryType.cql:
                input_task = Task.from_cql(query_spec, d)
            elif args.type == QueryType.vl:
                input_task = Task.from_vegalite(query_spec, d)

        if args.mode == Mode.violations:
            task = run(input_task, debug=args.debug, files=['define.lp', 'hard.lp', 'soft.lp', 'output.lp'], silence_warnings=True)

            if task:
                print(task.violations, file=args.out)
        elif args.mode == Mode.valid:
            task = run(input_task, debug=args.debug, files=['define.lp', 'hard.lp', 'output.lp'], silence_warnings=True)

            print('valid' if task else 'invalid', file=args.out)
        elif args.mode == Mode.optimize:
            task = run(input_task, debug=args.debug)

            if task:
                print(task.to_vegalite_json(), file=args.out)
                logger.info(f'Cost: {task.cost}')
                outname = 'stringIO' if isinstance(args.out, io.StringIO) else args.out.name
                logger.info(f'Wrote Vega-Lite spec to {outname}')

    # close open files
    if args.query is not sys.stdin:
        args.query.close()

    if args.out is not sys.stdout:
        args.out.close()


if __name__ == '__main__':  # pragma: no cover
    main()
