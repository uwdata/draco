'''
Use learn to rank to learn weights for soft constraints.
'''
import json
import os

import pandas as pd

from draco.spec import Data, Encoding, Field
from draco.util import count_violations, current_weights

path_worse = os.path.join(os.path.dirname(__file__), '../__tmp__/worse')
path_better = os.path.join(os.path.dirname(__file__), '../__tmp__/better')

def training_data():
    data = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], 100)

    # data, inferior spec, superior spec
    training_specs = [(data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q1', 'type': 'quantitative'}}}
    ), (data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    )]

    with open(os.path.join(os.path.dirname(__file__), '../data/training/q_q_n.json')) as f:
        qqn_data = json.load(f)
        for row in qqn_data:
            fields = list(map(Field.from_obj, row['fields']))
            data = Data(fields, int(row['num_rows']))
            training_specs.append((data, row['worse'], row['better']))

    return training_specs

def data_to_features(training):
    weights = current_weights()
    features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

    training_worse = pd.DataFrame(columns=features)
    training_better = pd.DataFrame(columns=features)

    # convert the specs to feature vectors
    for data, spec_worse, spec_better in training:
        training_worse = training_worse.append(count_violations(data, spec_worse), ignore_index=True)
        training_better = training_better.append(count_violations(data, spec_better), ignore_index=True)
        Encoding.encoding_cnt = 0

    return training_worse, training_better

def generate_and_store_features():
    training = training_data()
    training_worse, training_better = data_to_features(training)
    training_worse.to_pickle(path_worse)
    training_better.to_pickle(path_better)

def load_features():
    training_worse = pd.read_pickle(path_worse)
    training_better = pd.read_pickle(path_better)

    # learn the weights from the feature vectors
    print("worse:")
    print(training_worse)

    print("better:")
    print(training_better)

    return training_worse, training_better

if __name__ == '__main__':
    generate_and_store_features()
