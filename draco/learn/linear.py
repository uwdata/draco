'''
Use learn to rank to learn weights for soft constraints.
'''

import pandas as pd
import numpy as np
import sklearn.preprocessing as preproc
from sklearn import svm
import sklearn

from draco.spec import Data, Field
from draco.util import count_violations, current_weights


def get_example_specs():
    data = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], url='weather.csv')

    # data, inferior spec, superior spec
    example_specs = [(data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q1', 'type': 'quantitative'}}}
    ), (data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    ),(data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    ),(data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q2',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q2',' type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    ),(data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'color': {'field': 'q2', 'type': 'quantitative'}}}
    )]

    return example_specs


def extract_features(specs):

    weights = current_weights()
    features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

    better = pd.DataFrame(columns=features)
    worse = pd.DataFrame(columns=features)

    # convert the specs to feature vectors
    for d, spec1, spec2 in specs:
        better = better.append(count_violations(spec1, d), ignore_index=True)
        worse = worse.append(count_violations(spec2, d), ignore_index=True)

    # normalize the features by column
    def normalize(df):
        df.fillna(0, inplace=True)
        scaler = preproc.MinMaxScaler()
        df[df.columns] = scaler.fit_transform(df[df.columns])
        return df

    # concat and normalize and then split again
    normalized = normalize(pd.concat([better, worse]))
    loc = int(len(normalized) / 2)
    better = normalized.iloc[:loc]
    worse = normalized.iloc[loc:]

    X1 = better.values
    X2 = worse.values

    data = []
    for i in range(len(X1)):
        data.append((X1[i], X2[i], 1))
        data.append((X2[i], X1[i], -1))

    return data




def learn_weights(data):
    
    num_features = len(data[0][0])
    N = len(data)

    X = np.zeros((N, num_features))
    y = np.zeros(N)

    for i in range(len(data)):
        X[i] = data[i][0] - data[i][1]
        y[i] = data[i][2]

    X_train = X[:3]
    X_test = X[3:]

    y_train = y[:3]
    y_test = y[3:]

    clf = sklearn.linear_model.LogisticRegression() #svm.LinearSVC()
    clf.fit(X_train, y_train)  

    pred = clf.predict(X_test)
    print(pred)
    print(y_test)

    print(clf.coef_)

    # learn the weights from the feature vectors
    #print("better:")
    #print(training_better)

    #print("worse:")
    #print(training_worse)

if __name__ == '__main__':
    data = extract_features(get_example_specs())
    learn_weights(data)
