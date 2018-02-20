#!/usr/bin/env python3

import sys
import argparse
import logging
import io
import json
import os

from draco.run import run
from draco.spec import Task
from draco import __version__
from enum import Enum

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class QueryType(Enum):
    draco = 'draco'
    cql = 'cql'
    vl = 'vl'

    def __str__(self):
        return self.value

    @staticmethod
    def from_string(s):
        try:
            return QueryType[s]
        except KeyError:
            raise ValueError()

def create_parser():
    parser = argparse.ArgumentParser(description='Draco Visualization recommendation system.',
        epilog='There is a moment in every dawn when light floats, there is the possibility of magic. Creation holds its breath.')

    parser.add_argument('query', nargs='?', type=argparse.FileType('r'), default=sys.stdin,
                        help='The CompassQL query (partial Vega-Lite spec).')
    parser.add_argument('--type', '-t', type=QueryType, choices=list(QueryType), default=QueryType.draco,
                        help='Type of query. draco (Draco, default), cql (CompassQl), vl (Vega-Lite).')
    parser.add_argument('--out', '-o', nargs='?', type=argparse.FileType('w'), default=sys.stdout,
                        help='specify the Vega-Lite output file')
    parser.add_argument('--version', action='version',
                        version=__version__)

    return parser


def main():  # pragma: no cover
    parser = create_parser()
    args = parser.parse_args()

    logger.info(f'Processing query: {args.query.name} ...')

    # load a task from a spec provided by the user
    query_spec = json.load(args.query)
    d = os.path.dirname(args.query.name)
    if args.type == QueryType.draco:
        input_task = Task.from_obj(query_spec, d)
    elif args.type == QueryType.cql:
        input_task = Task.from_cql(query_spec, d)
    elif args.type == QueryType.vl:
        input_task = Task.from_vegalite(query_spec, d)

    task = run(input_task)

    if task:
        print(task.to_vegalite_json(), file=args.out)
        outname = 'stringIO' if isinstance(args.out, io.StringIO) else args.out.name
        logger.info(f'Wrote Vega-Lite spec to {outname}')

    # close open files
    if args.query is not sys.stdin:
        args.query.close()

    if args.out is not sys.stdout:
        args.out.close()


if __name__ == '__main__':  # pragma: no cover
    main()
