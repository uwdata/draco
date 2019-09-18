"""
Run constraint solver to complete spec.
"""

import json
import logging
import os
import subprocess
import tempfile
from collections import defaultdict
from typing import Dict, List, Optional, Tuple, Union

import clyngor
from clyngor.answers import Answers

from draco.js import asp2vl

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DRACO_LP = [
    "define.lp",
    "generate.lp",
    "hard.lp",
    "soft.lp",
    "weights.lp",
    "assign_weights.lp",
    "optimize.lp",
    "output.lp",
    "compare.lp",
    "assign_compare_weights.lp",
    "compare_hard.lp",
    "compare_weights.lp"
]
DRACO_LP_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../asp")


file_cache: Dict[str, bytes] = {}


class Result:
    props: Dict[str,List[str]]
    cost: Optional[int]
    violations: Dict[str, int]

    def __init__(self, answers: Answers, cost: Optional[int] = None) -> None:
        violations: Dict[str, int] = defaultdict(int)
        draco: Dict[str, int] = defaultdict(int)
        draco_list = []
        graphscape: Dict[str, int] = defaultdict(int)
        graphscape_list = []
        draco_weights: Dict[str, int] = defaultdict(int)
        graphscape_weights: Dict[str, int] = defaultdict(int)

        props: Dict[str,List[str]] = {}

        for ((head, body),) in answers:
            if head == "cost":
                cost = int(body[0])
            elif head == "soft":
                violations[body[0]] += 1
                draco[body[0]] += 1
                draco_list.append(body)
            elif head == "compare":
                violations[body[0]] += 1
                graphscape[body[0]] += 1
                graphscape_list.append(body)
            elif head == "soft_weight":
                draco_weights[body[0]] = body[1]
            elif head == "compare_weight":
                graphscape_weights[body[0]] = body[1]
            else:
                name = body[0]
                b = ",".join(map(str, body))
                if (name not in props):
                    props[name] = []

                props[name].append(f"{head}({b}).")

        # print(draco_weights)
        # print(draco)
        draco_weight = sum([v * draco_weights[k] for k,v in draco.items()])
        graphscape_weight = sum([v * graphscape_weights[k] for k,v in graphscape.items()])
        cost = draco_weight + graphscape_weight


        # print(graphscape_list)
        # if ('\"view\"' in props):
        #     print('\n'.join(props["\"view\""]))
        #     print()

        self.props = props
        self.violations = violations
        self.draco = draco
        self.graphscape = graphscape
        self.draco_weights = draco_weights
        self.graphscape_weights = graphscape_weights
        self.draco_list = draco_list
        self.graphscape_list = graphscape_list
        self.cost = cost
        self.d = draco_weight
        self.g = graphscape_weight

    def as_vl(self,v) -> Dict:
        specs = asp2vl(self.props[v])
        return specs[v]

def load_file(path: str) -> bytes:
    content = file_cache.get(path)
    if content is not None:
        return content
    with open(path) as f:
        content = f.read().encode("utf8")
        file_cache[path] = content
        return content


def run_clingo(
    draco_query: List[str],
    constants: Dict[str, str] = None,
    files: List[str] = None,
    silence_warnings=False,
    debug=False,
    topk=False,
    k=1,
) -> Tuple[str, str]:
    """
    Run draco and return stderr and stdout
    """
    # default args
    files = files or DRACO_LP
    files = files.copy()
    constants = constants or {}

    options = ["--outf=2", "--quiet=1,2,2", "--seed=0"]

    if (topk):
        files.append('topk-py.lp')
        options.append('--opt-mode=OptN')
        options.append("--models={0}".format(k))

    if silence_warnings:
        options.append("--warn=no-atom-undefined")
    for name, value in constants.items():
        options.append(f"-c {name}={value}")

    cmd = ["clingo"] + options
    logger.debug("Command: %s", " ".join(cmd))

    proc = subprocess.Popen(
        args=cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )

    program = "\n".join(draco_query)
    file_names = [os.path.join(DRACO_LP_DIR, f) for f in files]

    asp_program = b"\n".join(map(load_file, file_names)) + program.encode("utf8")

    if debug:
        with tempfile.NamedTemporaryFile(mode="w", delete=False) as fd:
            fd.write(program)

            logger.info('Debug ASP with "clingo %s %s"', " ".join(file_names), fd.name)
    
    stdout, stderr = proc.communicate(asp_program)
    return (stderr, stdout)


def run(
    draco_query: List[str],
    constants: Dict[str, str] = None,
    files: List[str] = None,
    silence_warnings=False,
    debug=False,
    clear_cache=False,
    topk=False,
    k=1,
) -> Optional[Result]:
    """ Run clingo to compute a completion of a partial spec or violations. """

    # Clear file cache. useful during development in notebooks.
    if clear_cache and file_cache:
        logger.warning("Cleared file cache")
        file_cache.clear()

    stderr, stdout = run_clingo(draco_query, constants, files, silence_warnings, debug, topk, k)

    try:
        json_result = json.loads(stdout)
    except json.JSONDecodeError:
        logger.error("stdout: %s", stdout)
        logger.error("stderr: %s", stderr)
        raise

    if stderr:
        logger.error(stderr)

    result = json_result["Result"]

    if result == "UNSATISFIABLE":
        # logger.info("Constraints are unsatisfiable.")
        if topk and json_result["Calls"] > 1:
            return run(draco_query, constants, files, silence_warnings, debug, clear_cache, topk, json_result["Calls"] - 1)
        return None
    elif result == "OPTIMUM FOUND":
        if (not topk):
            # get the last witness, which is the best result
            answers = json_result["Call"][0]["Witnesses"][-1]

            logger.debug(answers["Value"])

            result = Result(
                clyngor.Answers(answers["Value"]).sorted
            )

            return result
        else:
            results = []

            for call in json_result["Call"]:
                for answers in call["Witnesses"]:
                    result = Result(
                        clyngor.Answers(answers["Value"]).sorted
                    )
                    results.append(result)
            return results
    elif result == "SATISFIABLE":
        answers = json_result["Call"][0]["Witnesses"][-1]

        assert (
            json_result["Models"]["Number"] == 1
        ), "Should not have more than one model if we don't optimize"

        logger.debug(answers["Value"])

        return Result(clyngor.Answers(answers["Value"]).sorted)
    else:
        logger.error("Unsupported result: %s", result)
        return None
