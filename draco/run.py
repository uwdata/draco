"""
Run constraint solver to complete spec.
"""

import json
import logging
import os
import subprocess
from typing import Dict, List

import clyngor

from draco.spec import Task, Query

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DRACO_LP = ["define.lp", "generate.lp", "test.lp", "features.lp", "weights.lp", "optimize.lp", "output.lp"]
DRACO_LP_DIR = "asp"


def run(task: Task, constants: Dict[str, str] = {}, files: List[str] = DRACO_LP) -> Task:
    """ Run clingo to compute a completion of a partial spec or violations.
    """

    run_command = clyngor.command(
        files=[os.path.join(DRACO_LP_DIR, f) for f in files],
        inline=task.to_asp(),
        constants=constants,
        options=["--outf=2"])

    logger.info("Command: %s", " ".join(run_command))

    clingo = subprocess.run(run_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    stderr = clingo.stderr.decode("utf-8")
    stdout = clingo.stdout.decode("utf-8")

    try:
        json_result = json.loads(stdout)
    except json.JSONDecodeError:
        logger.error("stdout: %s", stdout)
        logger.error("stderr: %s", stderr)
        raise

    violations: Dict[str, int] = {}
    if stderr:
        try:
            violations = json.loads(stderr)
        except json.JSONDecodeError:
            logger.error(stderr)

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
    else:
        logger.error("Unsupported result: %s", result)
        return None
