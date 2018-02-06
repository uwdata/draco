'''
Use learn to rank to learn weights for soft constraints.
'''
import json
import os

from typing import List
import pandas as pd

from draco.spec import Data, Encoding, Field
from draco.util import count_violations, current_weights

def absolute_path(path):
    return os.path.join(os.path.dirname(__file__), path)

path_bad = absolute_path('../../__tmp__/feat_bad.csv')
path_good = absolute_path('../../__tmp__/feat_good.csv')

def get_data():
    spec_schema = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], 100)

    # data, inferior spec, superior spec
    examples = [(spec_schema,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q1', 'type': 'quantitative'}}}
    ), (spec_schema,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    )]

    with open(absolute_path('../../data/training/q_q_n.json')) as f:
        qqn_data = json.load(f)
        for row in qqn_data:
            fields = list(map(Field.from_obj, row['fields']))
            spec_schema = Data(fields, int(row['num_rows']))
            examples.append((spec_schema, row['worse'], row['better']))

    return examples

def examples_to_features(examples: List[tuple]) -> List[pd.DataFrame]:
    weights = current_weights()
    features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

    features_bad = pd.DataFrame(columns=features)
    features_good = pd.DataFrame(columns=features)

    # convert the specs to feature vectors
    for data, spec_bad, spec_good in examples:
        features_bad = features_bad.append(count_violations(data, spec_bad), ignore_index=True)
        features_good = features_good.append(count_violations(data, spec_good), ignore_index=True)
        Encoding.encoding_cnt = 0

    return features_bad, features_good

def generate_and_store_features():
    training = get_data()
    features_bad, features_good = examples_to_features(training)

    features_bad.to_csv(path_bad)
    features_good.to_csv(path_good)

def load_features():
    features_bad = pd.read_csv(path_bad)
    features_good = pd.read_csv(path_good)

    features_bad.fillna(0, inplace=True)
    features_good.fillna(0, inplace=True)

    return features_bad, features_good

if __name__ == '__main__':
    load_features()
