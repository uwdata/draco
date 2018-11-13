#!/usr/bin/env python3

import argparse
import io
import json
import logging
import os
import sys
from enum import Enum

from draco import __version__
from draco.js import vl2asp
from draco.run import run

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
    vl = "vl"
    asp = "asp"


class Mode(ArgEnum):
    optimize = "optimize"
    violations = "violations"
    valid = "valid"


def create_parser():
    parser = argparse.ArgumentParser(
        description="Draco Visualization recommendation system.",
        epilog="There is a moment in every dawn when light floats, there is the possibility of magic. Creation holds its breath. — Douglas Adams, The Hitchhikers Guide to the Galaxy",
    )

    parser.add_argument(
        "query",
        nargs="?",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help="The input query.",
    )
    parser.add_argument(
        "--type",
        "-t",
        type=QueryType,
        choices=list(QueryType),
        default=QueryType.asp,
        help="Type of query. asp (Answer Set Program, default) or vl (Vega-Lite).",
    )
    parser.add_argument(
        "--mode",
        "-m",
        type=Mode,
        choices=list(Mode),
        default=Mode.optimize,
        help="Mode to run draco in.",
    )
    parser.add_argument(
        "--out",
        "-o",
        type=argparse.FileType("w"),
        default=sys.stdout,
        help="specify the Vega-Lite output file",
    )
    parser.add_argument("--base", "-b", default=None, help="Base directory.")
    parser.add_argument(
        "--debug", "-d", help="Create debugging information.", action="store_true"
    )
    parser.add_argument("--version", action="version", version=__version__)

    return parser


def main():  # pragma: no cover
    parser = create_parser()
    args = parser.parse_args()

    if args.mode != Mode.optimize and (
        args.type == QueryType.draco or args.type == QueryType.cql
    ):
        print("Validation only works with full specs.", sys.stderr)
    else:
        logger.info(f"Processing query: {args.query.name} ...")

        if args.type == QueryType.asp:
            draco_query = args.query.read()
        else:
            query_spec = json.load(args.query)
            d = args.base or os.path.dirname(args.query.name)
            if args.type == QueryType.vl:
                draco_query = vl2asp(query_spec)

        if args.mode == Mode.violations:
            result = run(
                draco_query,
                debug=args.debug,
                files=["define.lp", "hard.lp", "soft.lp", "output.lp"],
                silence_warnings=True,
            )

            if result:
                print(result.violations, file=args.out)
        elif args.mode == Mode.valid:
            result = run(
                draco_query,
                debug=args.debug,
                files=["define.lp", "hard.lp", "output.lp"],
                silence_warnings=True,
            )

            print("valid" if result else "invalid", file=args.out)
        elif args.mode == Mode.optimize:
            result = run(draco_query, debug=args.debug)

            if result:
                print(result.as_vl(), file=args.out)
                logger.info(f"Cost: {result.cost}")
                outname = (
                    "stringIO" if isinstance(args.out, io.StringIO) else args.out.name
                )
                logger.info(f"Wrote Vega-Lite spec to {outname}")

    # close open files
    if args.query is not sys.stdin:
        args.query.close()

    if args.out is not sys.stdout:
        args.out.close()


if __name__ == "__main__":  # pragma: no cover
    main()
