'''
Processing data for learning procedures.
'''

import json
import os
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd

from draco.learn.helper import count_violations, current_weights
from draco.spec import Data, Encoding, Field, Query, Task


def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(__file__), p)

pickle_path = absolute_path('../../__tmp__/data.pickle')
yh_data_path = absolute_path('../../data/training/younghoon.json')
ba_data_path = absolute_path('../../data/training/bahador.json')

def get_raw_data():
    spec_schema = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], 100)

    # data, inferior spec, superior spec
    raw_data = [(spec_schema, None,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1', 'type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1', 'type': 'quantitative'}, 'y': {'field': 'q1', 'type': 'quantitative'}}}
    ), (spec_schema, None,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1', 'type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1', 'type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    )]

    for path in [yh_data_path, ba_data_path]:
        with open(path) as f:
            for row in json.load(f):
                fields = list(map(Field.from_obj, row['fields']))
                spec_schema = Data(fields, row.get('num_rows'))
                raw_data.append((spec_schema, row['task'], row['negative'], row['positive']))

    return raw_data

def get_index():
    # it gives you a pandas index that we apply to the data when creating a dataframe
    weights = current_weights()
    features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

    iterables = [['negative', 'positive'], features]
    index = pd.MultiIndex.from_product(iterables, names=['category', 'feature'])

    return index

def reformat(category: str, raw_data: Dict):
    '''
    Reformat the json data so that we can insert it int a multi index data frame.
    https://stackoverflow.com/questions/24988131/nested-dictionary-to-multiindex-dataframe-where-dictionary-keys-are-column-label
    '''
    return {(category, key): values for key, values in raw_data.items()}

def process_raw_data(raw_data: List[tuple]) -> List[pd.DataFrame]:
    index = get_index()
    df = pd.DataFrame(columns=index)

    processed_specs: Dict[str, int] = {}
    def count_violations_memoized(data, task, spec):
        key = data.to_asp() + ',' + json.dumps(spec)
        if key not in processed_specs:
            task = Task(data, Query.from_vegalite(spec), task)
            processed_specs[key] = count_violations(task)
        return processed_specs[key]

    # convert the specs to feature vectors
    for data, task, spec_neg, spec_pos in raw_data:
        Encoding.encoding_cnt = 0

        specs = reformat('negative', count_violations_memoized(data, task, spec_neg))
        specs.update(reformat('positive', count_violations_memoized(data, task, spec_pos)))

        df = df.append(pd.DataFrame(specs, index=[0]))

    return df.reset_index()

def generate_and_store_data():
    ''' Generate and store data in default path. '''
    raw_data = get_raw_data()
    data = process_raw_data(raw_data)
    data.to_pickle(pickle_path)

def load_data() -> pd.DataFrame:
    ''' Load data created with `generate_and_store_data`.
        Returns:
            a tuple containing: train_dev, test.
    '''
    data = pd.read_pickle(pickle_path)
    data.fillna(0, inplace=True)
    return split_dataset(data, ratio=0.7, seed=1)

#### data split functions

def split_dataset(data: pd.DataFrame, ratio: float=0.7, seed: int=1) -> Tuple[pd.DataFrame, pd.DataFrame]:
    # get the initial state of the RNG so that the seed does not rewrite random number state
    st0 = np.random.get_state()
    np.random.seed(seed)
    result = np.split(data.sample(frac=1), [
        int(ratio*len(data))
    ])
    np.random.set_state(st0)
    return result


if __name__ == '__main__':
    generate_and_store_data()
