"""
Helper functions for learning algorithm.
"""

import json
import os

from draco.run import run, DRACO_LP
from draco.spec import Task, Query

def list_weights():
    """ Get the current weights as a dictionary. """
    with open(os.path.join(os.path.dirname(__file__), "../data/weights.json")) as f:
        return json.load(f)

def count_violations(full_spec, data):
    """ Get a dictionary of violations for a full spec. """

    query = Query.from_obj(full_spec)
    input_task = Task(query, data)

    # TODO: we don't relaly need the output but the task parsing crashes if the output is bad
    task = run(input_task, files=DRACO_LP + ["count.lp"])
    return task.violations

def count_cost(violations, weights):
    # count the cost of the current full spec given weights
    pass

def solve_partial_spec(partial_spec, weights):
    # returns the best full spec with provided weights
    pass

## useful for initialization and normalization

def get_grounding_num(full_spec):
    # returns the number of groudings for each soft constraint
    # return in a dictionary
    pass

## todo later, for MC-SAT (sampling)

def get_soft_constraint(constraint_id):
    # returns the weight and the constraint text given its id
    pass

def sample_full_spec(partial_spec, extra_hard_constraints):
    # sample a solution by solving partial_spec
    # using original hard_constraints plus extra ones (extra_hard_constraints)
    pass
