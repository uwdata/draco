#!/usr/bin/env python3

import os
import sys
import json
import argparse
import subprocess
import logging
from pprint import pprint

from spec import *

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

CONFIG = {
    # the clingcon bin file
    "clingo": os.path.join("bin", "clingo-python-mac"),
    # vegalite file
    "vega_lite_lp": os.path.join("asp", "vega-lite.lp"),
    # the directory storing temporary files
    # (e.g., lp files compiled from partial spec)
    "tmp_dir": "__tmp__"
}

# create tmp dir if not exists
if not os.path.exists(CONFIG["tmp_dir"]):
    os.makedirs(CONFIG["tmp_dir"])


def main(partial_vl_spec, out):
    """ Given a partial vegalite spec, recommand a completion of the spec
    """
    tmp_asp_file = os.path.join(CONFIG["tmp_dir"], os.path.basename(partial_vl_spec.name).split(".")[0] + ".lp")

    # load a task from a spec provided by the user
    task = Task.load_from_vl_json(partial_vl_spec)

    with open(tmp_asp_file, "w") as f:
        logger.info(f"Temp asp specification written into: {tmp_asp_file}.")
        f.write(task.to_asp())

    r = subprocess.run([CONFIG["clingo"], CONFIG["vega_lite_lp"], tmp_asp_file, "--outf=2"],
                       stdout=subprocess.PIPE, stderr=None)

    json_result = json.loads(r.stdout.decode("utf-8"))

    result = json_result["Result"]

    if result == "UNSATISFIABLE":
        logger.info("Constraints are unsatisfiable.")
    elif result == "OPTIMUM FOUND":
        raw_str_list = json_result["Call"][0]["Witnesses"][0]["Value"]
    
        logger.info(raw_str_list)

        query = Query.parse_from_asp_result(raw_str_list)
        new_task = Task(task.data, query)

        print(new_task.to_vl_json(), file=out)
        logger.info(f"Wrote Vega-Lite spec to {out.name}.")

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Visualization recommendation system.",
        epilog="There is a moment in every dawn when light floats, there is the possibility of magic. Creation holds its breath.")

    parser.add_argument("query", nargs="?", type=argparse.FileType("r"), default=sys.stdin,
                        help="The CompassQL query (partial Vega-Lite spec).")
    parser.add_argument("--out", nargs="?", type=argparse.FileType("w"), default=sys.stdout,
                        help="Where to output the Vega-Lite spec.")
    args = parser.parse_args()

    logger.info(f"Processing partial vis spec: {args.query.name} ...")

    main(args.query, args.out)

    # close open files
    if args.query is not sys.stdin:
        args.query.close()

    if args.out is not sys.stdout:
        args.out.close()

    logger.info(f"Complete task.")
