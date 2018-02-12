#Processing data for learning procedures.

import json
import os
from typing import Dict, List

import pandas as pd
import numpy as np

from draco.learn.helper import count_violations, current_weights
from draco.spec import Data, Encoding, Field


def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(__file__), p)

pickle_path = absolute_path('../../__tmp__/data.pickle')
user_study_data_path = absolute_path('../../data/training/q_q_n.json')

def get_raw_data():
    spec_schema = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], 100)

    # data, inferior spec, superior spec
    raw_data = [(spec_schema,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q1', 'type': 'quantitative'}}}
    ), (spec_schema,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    )]

    with open(user_study_data_path) as f:
        qqn_data = json.load(f)
        for row in qqn_data:
            fields = list(map(Field.from_obj, row['fields']))
            spec_schema = Data(fields, int(row['num_rows']))
            raw_data.append((spec_schema, row['negative'], row['positive']))

    return raw_data

def get_index():
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

    processed_specs = {}
    def count_violations_memoized(data, spec):
        key = data.to_asp() + ',' + json.dumps(spec)
        if key not in processed_specs:
            processed_specs[key] = count_violations(data, spec)
        return processed_specs[key]

    # convert the specs to feature vectors
    for data, spec_neg, spec_pos in raw_data:
        Encoding.encoding_cnt = 0
        specs = reformat('negative', count_violations_memoized(data, spec_neg))
        specs.update(reformat('positive', count_violations_memoized(data, spec_pos)))

        df = df.append(pd.DataFrame(specs, index=[0]))

    return df.reset_index()

def generate_and_store_data():
    ''' Generate and store data in default path. '''
    raw_data = get_raw_data()
    data = process_raw_data(raw_data)
    data.to_pickle(pickle_path)

def load_data() -> pd.DataFrame:
    ''' Load data created with `generate_and_store_data`. '''
    data = pd.read_pickle(pickle_path)
    data.fillna(0, inplace=True)
    return data

#### data split functions

def split_dataset(data, ratio=0.7, seed=1):
    np.random.seed(seed)

    return np.split(data.sample(frac=1), [
        int(ratio*len(data))
    ])

def rand_split_XY(X, y, ratio=0.7, seed=1):
    """ Split matrices X, y together,
        so that X[i], y[i] pairing relation is retained
    """
    np.random.seed(seed)

    indexes = [i for i in range(len(X))]
    np.random.shuffle(indexes)

    X = [X[i] for i in indexes]
    y = [y[i] for i in indexes]

    X1, X2 = np.split(X, [int(len(X) * ratio)])
    y1, y2 = np.split(y, [int(len(y) * ratio)])

    return X1, y1, X2, y2

if __name__ == '__main__':
    generate_and_store_data()
