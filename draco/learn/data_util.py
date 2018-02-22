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
user_study_data_path = absolute_path('../../data/training/q_q_n.json')
compassql_data_path = absolute_path("../../data/compassql_examples")

def load_neg_pos_data():

    spec_schema = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], 100)

    # data, inferior spec, superior spec
    raw_data = [(spec_schema,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1', 'type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1', 'type': 'quantitative'}, 'y': {'field': 'q1', 'type': 'quantitative'}}}
    ), (spec_schema,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1', 'type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1', 'type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    )]

    with open(user_study_data_path) as f:
        qqn_data = json.load(f)
        for row in qqn_data:
            fields = list(map(Field.from_obj, row['fields']))
            spec_schema = Data(fields, int(row['num_rows']))
            raw_data.append((spec_schema, row['negative'], row['positive']))

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


def to_feature_vec(neg_pos_data: List[tuple]) -> List[pd.DataFrame]:
    """ given neg_pos_data, convert them into feature vectors """

    def get_index():
        # it gives you a pandas index that we apply to the data when creating a dataframe
        weights = current_weights()
        features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

        iterables = [['negative', 'positive'], features]
        index = pd.MultiIndex.from_product(iterables, names=['category', 'feature'])
        return index

    def count_violations_memoized(data, spec):
        key = data.to_asp() + ',' + json.dumps(spec)
        if key not in processed_specs:
            task = Task(data, Query.from_vegalite(spec))
            processed_specs[key] = count_violations(task)
        return processed_specs[key]

    index = get_index()
    df = pd.DataFrame(columns=index)

    processed_specs: Dict[str, int] = {}

    # convert the specs to feature vectors
    for data, spec_neg, spec_pos in neg_pos_data:
        Encoding.encoding_cnt = 0

        neg_feature_vec = count_violations_memoized(data, spec_neg)
        pos_feature_vec = count_violations_memoized(data, spec_pos)
        
        # Reformat the json data so that we can insert it int a multi index data frame.
        # https://stackoverflow.com/questions/24988131/nested-dictionary-to-multiindex-dataframe-where-dictionary-keys-are-column-label
        specs = {('negative', key): values for key, values in neg_feature_vec.items()}
        specs.update({('positive', key): values for key, values in pos_feature_vec.items()})

        df = df.append(pd.DataFrame(specs, index=[0]))

    return df.reset_index()

def generate_and_store_data():
    ''' Generate and store data in default path. '''
    raw_data = load_neg_pos_data()
    data = to_feature_vec(raw_data)
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
