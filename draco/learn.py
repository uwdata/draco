'''
Use learn to rank to learn weights for soft constraints.
'''
import json
import os

import numpy as np
import pandas as pd
import sklearn.preprocessing as preproc

from draco.spec import Data, Encoding, Field
from draco.util import count_violations, current_weights


def training_data():
    data = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], 100, url='weather.csv')

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


def learn_weights():
    training = training_data()

    print(training[:10])

    weights = current_weights()
    features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

    training_better = pd.DataFrame(columns=features)
    training_worse = pd.DataFrame(columns=features)

    # convert the specs to feature vectors
    for data, spec_worse, spec_better in training:
        training_worse = training_worse.append(count_violations(data, spec_worse), ignore_index=True)
        training_better = training_better.append(count_violations(data, spec_better), ignore_index=True)
        Encoding.encoding_cnt = 0

    # normalize the features by column
    def normalize(df):
        df.fillna(0, inplace=True)
        # scalers: http://scikit-learn.org/stable/modules/classes.html#module-sklearn.preprocessing
        scaler = preproc.MinMaxScaler()
        df[df.columns] = scaler.fit_transform(df[df.columns])
        return df

    # concat and normalize and then split again
    normalized = normalize(pd.concat([training_better, training_worse]))
    loc = int(len(normalized) / 2)
    training_better = normalized.iloc[:loc]
    training_worse = normalized.iloc[loc:]

    # learn the weights from the feature vectors
    print("better:")
    print(training_better)

    print("worse:")
    print(training_worse)

if __name__ == '__main__':
    learn_weights()
