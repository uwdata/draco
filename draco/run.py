"""
Run constraint solver to complete spec.
"""

import os
import json
import subprocess
import logging

from draco.spec import Task, Query

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DRACO_LP = ["define.lp", "generate.lp", "test.lp", "optimize.lp", "output.lp"]
DRACO_LP_DIR = "asp"
TMP_DIR = "__tmp__"


def build_args(draco_lp_dir, tmp_asp_file, constants):
    const_args = [f"{arg[0]}={arg[1]}" for arg in constants.items()]
    if len(const_args):
        const_args = ["--consts"] + const_args
    return [os.path.join(draco_lp_dir, f) for f in DRACO_LP] + [tmp_asp_file, "--outf=2"] + const_args


def run(partial_vl_spec, tmp_dir=TMP_DIR, draco_lp_dir=DRACO_LP_DIR, constants={}):
    """ Given a partial vegalite spec, recommand a completion of the spec
    """

    # create tmp dir if not exists
    if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)

    tmp_asp_file = os.path.join(tmp_dir, os.path.basename(partial_vl_spec.name).split(".")[0] + ".lp")

    # load a task from a spec provided by the user
    task = Task.load_from_json(partial_vl_spec)

    with open(tmp_asp_file, "w") as f:
        logger.info(f"Temp asp specification written into: {tmp_asp_file}.")
        f.write(task.to_asp())

    r = subprocess.run(["clingo"] + build_args(draco_lp_dir, tmp_asp_file, constants),
                       stdout=subprocess.PIPE, stderr=None)

    json_result = json.loads(r.stdout.decode("utf-8"))

    result = json_result["Result"]

    if result == "UNSATISFIABLE":
        logger.info("Constraints are unsatisfiable.")
        return None
    elif result == "OPTIMUM FOUND":
        raw_str_list = json_result["Call"][0]["Witnesses"][0]["Value"]

        logger.info(raw_str_list)

        query = Query.parse_from_asp_result(raw_str_list)
        return Task(task.data, query)
