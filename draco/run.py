import os
import json
import subprocess
import logging
from pprint import pprint
import io

from draco.spec import Task, Query

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

CONFIG = {
    "draco_lp": ["define.lp", "generate.lp", "test.lp", "optimize.lp", "output.lp"],
    # the directory storing temporary files
    # (e.g., lp files compiled from partial spec)
    "tmp_dir": "__tmp__",
    "draco_lp_dir": "asp" 
}


def run(partial_vl_spec, out, tmp_dir=CONFIG["tmp_dir"], draco_lp_dir=CONFIG["draco_lp_dir"]):
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

    r = subprocess.run(["clingo"] + [os.path.join(draco_lp_dir, f) for f in CONFIG["draco_lp"]] + [tmp_asp_file, "--outf=2"],
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

        print(new_task.to_vegalite_json(), file=out)
        outname = "stringIO" if isinstance(out, io.StringIO) else out.name
        logger.info(f"Wrote Vega-Lite spec to {outname}.")
