import json

from draco.run import run_draco
from draco.spec import Task


def is_valid(task: Task, debug=False) -> bool:
    """ Check a task.
        Args:
            task: a task spec object
        Returns:
            whether the task is valid
    """
    program = task.to_asp_list()
    _, stdout = run_draco(
        program, files=["define.lp", "hard.lp"], silence_warnings=True, debug=debug
    )

    return json.loads(stdout)["Result"] != "UNSATISFIABLE"
