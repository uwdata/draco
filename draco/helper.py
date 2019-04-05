import json
from typing import Dict, List

import pandas as pd

from draco.js import data2schema, schema2asp
from draco.run import run_clingo


def is_valid(draco_query: List[str], debug=False) -> bool:
    """ Check a task.
        Args:
            draco_query: a list of facts
        Returns:
            whether the task is valid
    """
    _, stdout = run_clingo(
        draco_query,
        files=["define.lp", "hard.lp", "hard-integrity.lp"],
        silence_warnings=True,
        debug=debug,
    )

    return json.loads(stdout)["Result"] != "UNSATISFIABLE"


def data_to_asp(data: List) -> List[str]:
    """ Reads the data array and generates the ASP definition.
        Args:
            file: the data as a list of objects
        Returns:
            the asp definition.
    """
    return schema2asp(data2schema(data))


def read_data_to_asp(file: str) -> List[str]:
    """ Reads the given JSON file and generates the ASP definition.
        Args:
            file: the json data file
        Returns:
            the asp definition.
    """
    if file.endswith(".json"):
        with open(file) as f:
            data = json.load(f)
            return schema2asp(data2schema(data))
    elif file.endswith(".csv"):
        df = pd.read_csv(file)
        df = df.where((pd.notnull(df)), None)
        data = list(df.T.to_dict().values())
        schema = data2schema(data)
        asp = schema2asp(schema)
        return asp
    else:
        raise Exception("invalid file type")
