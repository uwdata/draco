'''
Use learn to rank to learn weights for soft constraints.
'''

import pandas as pd
import numpy as np
import sklearn.preprocessing as preproc

from draco.spec import Data, Field
from draco.util import count_violations, current_weights


def learn_weights():
    data = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], url='weather.csv')

    # data, inferior spec, superior spec
    training_specs = [(data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q1', 'type': 'quantitative'}}}
    ), (data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    )]

    weights = current_weights()
    features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

    training_better = pd.DataFrame(columns=features)
    training_worse = pd.DataFrame(columns=features)

    # convert the specs to feature vectors
    for data, spec1, spec2 in training_specs:
        training_better = training_better.append(count_violations(spec1, data), ignore_index=True)
        training_worse = training_worse.append(count_violations(spec2, data), ignore_index=True)

    def normalize(df):
        df.fillna(0, inplace=True)
        scaler = preproc.StandardScaler()
        df[df.columns] = scaler.fit_transform(df[df.columns])
        return df

    training_better = normalize(training_better)
    training_worse = normalize(training_worse)

    # learn the weights from the feature vectors
    print(training_better)
    print(training_worse)

if __name__ == '__main__':
    learn_weights()
