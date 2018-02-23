'''
Helper functions for learning algorithm.
'''

import json
import os
from typing import Dict, Tuple

from draco.run import DRACO_LP, run
from draco.spec import Data, Query, Task

def current_weights() -> Dict:
    ''' Get the current weights as a dictionary. '''
    with open(os.path.join(os.path.dirname(__file__), '../../data/weights.json')) as f:
        return json.load(f)

def compute_cost(violations: Dict) -> int:
    weights = current_weights()
    c = 0
    for k,v in violations.items():
        c += v * weights[f'{k}_weight']
    return c    

def count_violations(task: "Task") -> Dict:
    ''' Get a dictionary of violations for a full spec. 
        Args:
            task: a task spec object
        Returns:
            a dictionary storing violations of soft rules
    '''
    task = run(task, files=['define.lp', 'features.lp', 'output.lp', 'count.lp'], silence_warnings=True)
    return task.violations

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
