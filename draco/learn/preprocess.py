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

path_neg = absolute_path('../../__tmp__/data_negative.csv')
path_pos = absolute_path('../../__tmp__/data_positive.csv')

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

    with open(absolute_path('../../data/training/q_q_n.json')) as f:
        qqn_data = json.load(f)
        for row in qqn_data:
            fields = list(map(Field.from_obj, row['fields']))
            spec_schema = Data(fields, int(row['num_rows']))
            raw_data.append((spec_schema, row['worse'], row['better']))

    return raw_data

def process_raw_data(raw_data: List[tuple]) -> List[pd.DataFrame]:
    weights = current_weights()
    features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

    data_neg = pd.DataFrame(columns=features)
    data_pos = pd.DataFrame(columns=features)

    # convert the specs to feature vectors
    for data, spec_neg, spec_pos in raw_data:
        data_neg = data_neg.append(count_violations(data, spec_neg), ignore_index=True)
        data_pos = data_pos.append(count_violations(data, spec_pos), ignore_index=True)
        Encoding.encoding_cnt = 0

    return data_neg, data_pos

def generate_and_store_data():
    raw_data = get_raw_data()
    data_neg, data_pos = process_raw_data(raw_data)

    data_neg.to_csv(path_neg)
    data_pos.to_csv(path_pos)

def load_data():
    data_neg = pd.read_csv(path_neg)
    data_pos = pd.read_csv(path_pos)

    data_neg.fillna(0, inplace=True)
    data_pos.fillna(0, inplace=True)

    return data_neg, data_pos

if __name__ == '__main__':
    generate_and_store_data()
