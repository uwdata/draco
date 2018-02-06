'''
Use learn to rank to learn weights for soft constraints.
'''

import pandas as pd
import numpy as np
import sklearn.preprocessing as preproc
from sklearn import svm
import sklearn
import matplotlib.pyplot as plt

from draco.spec import Data, Field
from draco.learn.helper import count_violations, current_weights
from draco.learn import preprocess

from sklearn.decomposition import PCA
import sys

np.random.seed(1)

def prepare_data(data_pos, data_neg):

    N = len(data_pos)
    num_features = len(data_pos.columns)

    X = np.zeros((N, num_features))
    y = np.zeros(N)

    for i in range(N):

        x_pos = data_pos.iloc[i].values
        x_neg = data_neg.iloc[i].values

        feed_pos = np.random.choice([True, False])

        #if feed_pos:
        X[i] = x_pos - x_neg
        y[i] = 1 if feed_pos else 0
        #else:
        #    X[i] = x_neg - x_pos
        #    y[i] = 0

    return X, y

def learn_weights(X_train, y_train, X_dev, y_dev):

    #clf = sklearn.linear_model.LogisticRegression() 
    clf = svm.LinearSVC()
    clf.fit(X_train, y_train)  

    #pred = clf.predict(X_dev)
    #score = clf.score(X_dev, y_dev)
    print(clf.score(X_train, y_train))
    print(clf.score(X_dev, y_dev))
    #print(y_test)

    #print(clf.coef_)

    used_feat_idx = [i for i in range(len(clf.coef_[0])) if clf.coef_[0][i] != 0.]

    return used_feat_idx

def plot_data(X, y):
    pca = PCA(n_components=2)
    X2 = pca.fit_transform(X)

    x_11 = [X2[i][0] for i in range(len(X2)) if y[i] == 0]
    x_12 = [X2[i][1] for i in range(len(X2)) if y[i] == 0]

    x_21 = [X2[i][0] for i in range(len(X2)) if y[i] == 1]
    x_22 = [X2[i][1] for i in range(len(X2)) if y[i] == 1]

    plt.scatter(x_11, x_12, marker='^', c='r')
    plt.scatter(x_21, x_22, marker='o', c='b')
    plt.show()


if __name__ == '__main__':

    data = preprocess.load_data()


    print(data["negative"])
    print(data["positive"])
    print(len(data))

    sys.exit(-1)

    N = len(data)

    indexes = np.arange(N)
    np.random.shuffle(indexes)
    train_split = 0.7
    dev_split = 0.1
    test_split = 0.2

    train_indexes = indexes[:int(N * train_split)]
    dev_indexes = indexes[int(N * train_split): int(N * (train_split + dev_split))]
    test_indexes = indexes[int(N * (train_split + dev_split)):]

    train_neg = data_neg.iloc[train_indexes]
    train_pos = data_pos.iloc[train_indexes]

    dev_neg = data_neg.iloc[dev_indexes]
    dev_pos = data_pos.iloc[dev_indexes]
    
    X_train, y_train = prepare_data(train_pos, train_neg)
    X_dev, y_dev = prepare_data(dev_pos, dev_neg)

    used_features = learn_weights(X_train, y_train, X_dev, y_dev)

    print([data_pos.columns[i] for i in used_features])

    plot_data(X_train, y_train)

    #X = np.zeros()
    #learn_weights(data)



