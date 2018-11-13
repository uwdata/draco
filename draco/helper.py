import json

from draco.run import run_clingo
from draco.spec import Task
from typing import List


def is_valid(draco_query: List[str], debug=False) -> bool:
    """ Check a task.
        Args:
            draco_query: a list of facts
        Returns:
            whether the task is valid
    """
    _, stdout = run_clingo(
        draco_query, files=["define.lp", "hard.lp"], silence_warnings=True, debug=debug
    )

    return json.loads(stdout)["Result"] != "UNSATISFIABLE"
