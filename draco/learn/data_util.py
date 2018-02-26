'''
Processing data for learning procedures.
'''

import json
import os
from collections import namedtuple
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

from draco.learn.helper import count_violations, current_weights
from draco.spec import Data, Encoding, Field, Query, Task


def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(__file__), p)

pickle_path = absolute_path('../../__tmp__/data.pickle')
man_data_path = absolute_path('../../data/training/manual.json')
yh_data_path = absolute_path('../../data/training/younghoon.json')
ba_data_path = absolute_path('../../data/training/bahador.json')
compassql_data_path = absolute_path("../../data/compassql_examples")


PosNegExample = namedtuple('PosNeg', ['data', 'task', 'source', 'negative', 'positive'])


def load_neg_pos_data() -> List[PosNegExample]:
    raw_data = []

    for path in [man_data_path, yh_data_path, ba_data_path]:
        with open(path) as f:
            json_data = json.load(f)

            for row in json_data['data']:
                fields = list(map(Field.from_obj, row['fields']))
                spec_schema = Data(fields, row.get('num_rows'))
                raw_data.append(PosNegExample(
                    spec_schema,
                    row.get('task'),
                    json_data['source'],
                    row['negative'],
                    row['positive'])
                )

    return raw_data


def load_partial_full_data():
    """ load partial-full spec pairs from the directory
        Args:
            compassql_data_dir: the directory containing compassql data with
                 "input" and "output" directories specifying compassql input and output
        Returns:
            A dictionary mapping each case name into a pair of partial spec - full spec.
    """

    def load_spec(input_dir, format="compassql"):
        """ load compassql data
            Args: input_dir: the directory containing a set of json compassql specs
                  format: one of "compassql" and "vegalite"
            Returns:
                a dictionary containing name and the Task object representing the spec
        """
        files = [os.path.join(input_dir, f) for f in os.listdir(input_dir)]
        result = {}
        for fname in files:
            with open(fname, 'r') as f:
                content = json.load(f)
                content["data"]["url"] = os.path.join(input_dir, content["data"]["url"])
                if format == "compassql":
                    spec = Task.from_cql(content, ".")
                elif format == "vegalite":
                    spec = Task.from_vegalite(content)
                result[os.path.basename(fname)] = spec
        return result

    partial_specs = load_spec(os.path.join(compassql_data_path, "input"), "compassql")
    compassql_outs = load_spec(os.path.join(compassql_data_path, "output"), "vegalite")

    result = {}
    for k in partial_specs:
        result[k] = (partial_specs[k], compassql_outs[k])
    return result


def to_feature_vec(neg_pos_data: List[PosNegExample]) -> pd.DataFrame:
    """ given neg_pos_data, convert them into feature vectors """

    def get_index():
        # it gives you a pandas index that we apply to the data when creating a dataframe
        weights = current_weights()
        features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

        iterables = [['negative', 'positive'], features]
        index = pd.MultiIndex.from_product(iterables, names=['category', 'feature'])
        return index

    def count_violations_memoized(data, task, spec):
        key = data.to_asp() + ',' + json.dumps(spec)
        if key not in processed_specs:
            task = Task(data, Query.from_vegalite(spec), task)
            processed_specs[key] = count_violations(task)
        return processed_specs[key]

    index = get_index()
    df = pd.DataFrame(columns=index)

    processed_specs: Dict[str, int] = {}

    # convert the specs to feature vectors
    for idx, example in enumerate(neg_pos_data):
        Encoding.encoding_cnt = 0

        neg_feature_vec = count_violations_memoized(example.data, example.task, example.negative)
        pos_feature_vec = count_violations_memoized(example.data, example.task, example.positive)

        # Reformat the json data so that we can insert it int a multi index data frame.
        # https://stackoverflow.com/questions/24988131/nested-dictionary-to-multiindex-dataframe-where-dictionary-keys-are-column-label
        specs = {('negative', key): values for key, values in neg_feature_vec.items()}
        specs.update({('positive', key): values for key, values in pos_feature_vec.items()})

        df = df.append(pd.DataFrame(specs, index=[idx]))  # the idx is the same as the one in load_neg_pos_data

    return df

def get_pos_neg_data() -> pd.DataFrame:
    '''
    Load data created with `generate_and_store_data`.
    '''

    data = pd.read_pickle(pickle_path)
    data.fillna(0, inplace=True)

    return data

def paired_train_test_split(X: np.array, y: np.array, test_size: float=0.3, random_state=1) -> Tuple[np.array, np.array, np.array, np.array]:
    '''
    Split a dataset that has paired examples into train and test data.
    '''
    np.random.seed(random_state)

    size = int(len(X) / 2)
    assert sum(y[:size]) == 0
    assert sum(y[size:]) == size

    idx = np.ones(size, dtype=bool)
    idx[:int(test_size * size)] = False
    np.random.shuffle(idx)

    idx = np.concatenate([idx, idx])

    return X[idx], X[~idx], y[idx], y[~idx]

def load_data(test_size: float=0.3, random_state=1) -> Tuple[pd.DataFrame, pd.DataFrame]:
    '''
        Returns:
            a tuple containing: train_dev, test.
    '''
    data = get_pos_neg_data()

    return train_test_split(data, test_size=test_size, random_state=random_state)

if __name__ == '__main__':
    ''' Generate and store data in default path. '''
    neg_pos_data = load_neg_pos_data()
    data = to_feature_vec(neg_pos_data)
    data.to_pickle(pickle_path)
