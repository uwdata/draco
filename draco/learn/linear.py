import matplotlib.pyplot as plt

import numpy as np
import pandas as pd
import sklearn
import sklearn.preprocessing as preproc
from sklearn import svm
from sklearn.decomposition import PCA

from draco.learn import data_util
from draco.learn.helper import count_violations, current_weights
from draco.spec import Data, Field

def prepare_data(data):

    N = len(data)
    num_features = len(data["positive"].columns)

    X = np.zeros((2 * N, num_features))
    y = np.zeros(2 * N)

    for i in range(N):

        x_pos = data["positive"].iloc[i].values
        x_neg = data["negative"].iloc[i].values

        X[i] = x_pos - x_neg
        y[i] = 1

        X[i + N] = x_neg - x_pos
        y[i + N] = 0

    return X, y


def learn_weights(X_train, y_train, X_dev, y_dev):

    #clf = sklearn.linear_model.LogisticRegression()
    clf = svm.LinearSVC(C=.1)
    clf.fit(X_train, y_train)
    coef = clf.coef_.ravel() / np.linalg.norm(clf.coef_)
    #print(coef)

    print(clf.score(X_train, y_train))
    print(clf.score(X_dev, y_dev))



def plot_data(X, y):

    print(len(list(set([tuple([int(t) for t in x]) for x in X]))))

    pca = PCA(n_components=2)
    X = pca.fit_transform(X)

    labels = list(set(y))

    class_label = [('^', 'r'), ('o', 'b'), ('*', 'b'), ('*', 'y'), ('*', 'b')]

    for v in labels:
        x1 = [X[i][0] for i in range(len(X)) if y[i] == v]
        x2 = [X[i][1] for i in range(len(X)) if y[i] == v]

        label = class_label[labels.index(v)]
        plt.scatter(x1, x2, marker=label[0], c=label[1])

    return plt

if __name__ == '__main__':

    data = data_util.load_data()

    train_data, dev_data, _ = data_util.split_dataset(data)

    X_train, y_train = prepare_data(train_data)
    X_dev, y_dev = prepare_data(dev_data)

    learn_weights(X_train, y_train, X_dev, y_dev)
    
    plt = plot_data(*prepare_data(train_data))    
    #plt = plot_data(*prepare_data(dev_data))
    plt.show()


