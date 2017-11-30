"""
Run constraint solver to complete spec.
"""

import json
import logging
import os
import subprocess

import clyngor

from draco.spec import Task, Query

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DRACO_LP = ["define.lp", "generate.lp", "test.lp", "optimize.lp", "output.lp", "count.lp"]
DRACO_LP_DIR = "asp"


def run(partial_vl_spec, constants={}):
    """ Given a partial vegalite spec, recommand a completion of the spec
    """

    # load a task from a spec provided by the user
    task = Task.load_from_json(partial_vl_spec)

    run_command = clyngor.command(
        files=[os.path.join(DRACO_LP_DIR, f) for f in DRACO_LP],
        inline=task.to_asp(),
        constants=constants,
        options=["--outf=2"])

    logger.info("Command: %s", " ".join(run_command))

    clingo = subprocess.run(run_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    json_result = json.loads(clingo.stdout.decode("utf-8"))

    stderr = clingo.stderr.decode("utf-8")
    violations = json.loads(stderr) if stderr else {}

    result = json_result["Result"]

    if result == "UNSATISFIABLE":
        logger.info("Constraints are unsatisfiable.")
        return None
    elif result == "OPTIMUM FOUND":
        # get the last witness, which is the best result
        answers = json_result["Call"][0]["Witnesses"][-1]["Value"]

        logger.info(answers)

        query = Query.parse_from_answer(clyngor.Answers(answers).sorted)
        return Task(task.data, query, violations)
