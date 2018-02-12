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

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_parser():
    parser = argparse.ArgumentParser(description='Draco Visualization recommendation system.',
        epilog='There is a moment in every dawn when light floats, there is the possibility of magic. Creation holds its breath.')

    parser.add_argument('query', nargs='?', type=argparse.FileType('r'), default=sys.stdin,
                        help='The CompassQL query (partial Vega-Lite spec).')
    parser.add_argument('--out', nargs='?', type=argparse.FileType('w'), default=sys.stdout,
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
    input_task = Task.from_obj(query_spec, os.path.dirname(args.query.name))

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
