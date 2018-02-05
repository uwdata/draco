'''
Helper functions for learning algorithm.
'''

import json
import os
from typing import Dict

from draco.run import DRACO_LP, run
from draco.spec import Query, Task, Data


def current_weights() -> Dict:
    ''' Get the current weights as a dictionary. '''
    with open(os.path.join(os.path.dirname(__file__), '../data/weights.json')) as f:
        return json.load(f)

def count_violations(data: Data, full_spec: Dict) -> Dict:
    ''' Get a dictionary of violations for a full spec. '''

    query = Query.from_vegalite(full_spec)
    input_task = Task(data, query)

    task = run(input_task, files=DRACO_LP + ['count.lp'])
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
