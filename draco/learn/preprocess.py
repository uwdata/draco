'''
Use learn to rank to learn weights for soft constraints.
'''
import json
import os

from typing import List, Dict
import pandas as pd

from draco.spec import Data, Encoding, Field
from draco.util import count_violations, current_weights

def absolute_path(path: str) -> str:
    return os.path.join(os.path.dirname(__file__), path)

path_neg = absolute_path('../../__tmp__/data_negative.csv')
path_pos = absolute_path('../../__tmp__/data_positive.csv')
path = absolute_path('../../__tmp__/data.pickle')

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

    # convert the specs to feature vectors
    for data, spec_neg, spec_pos in raw_data:
        Encoding.encoding_cnt = 0
        specs = reformat('negative', count_violations(data, spec_neg))
        specs.update(reformat('positive', count_violations(data, spec_pos)))

        df = df.append(pd.DataFrame(specs, index=[]))

    return df.reset_index()

def generate_and_store_data():
    raw_data = get_raw_data()

    data = process_raw_data(raw_data)
    data.to_pickle(path)

def load_data():
    data = pd.read_pickle(path)

    data.fillna(0, inplace=True)

    return data

if __name__ == '__main__':
    generate_and_store_data()
