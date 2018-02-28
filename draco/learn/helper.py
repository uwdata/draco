'''
Helper functions for learning algorithm.
'''

import json
import os
from typing import Dict, Tuple

import numpy as np

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

def count_violations(task: Task) -> Dict:
    ''' Get a dictionary of violations for a full spec.
        Args:
            task: a task spec object
        Returns:
            a dictionary storing violations of soft rules
    '''
    task = run(task, files=['define.lp', 'features.lp', 'output.lp', 'count.lp'], silence_warnings=True)
    return task.violations


def contingency_table(labels_1: np.array, labels_2: np.array) -> np.array:
    '''
    Compute a contingency table for two arrays of booleans.
    '''
    return [[np.sum(labels_1), len(labels_1) - np.sum(labels_1)],
            [np.sum(labels_2), len(labels_2) - np.sum(labels_2)]]

