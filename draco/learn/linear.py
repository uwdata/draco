from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn import svm
from sklearn.decomposition import PCA

from draco.learn import data_util


def prepare_data(data: pd.DataFrame) -> Tuple[pd.DataFrame, pd.DataFrame]:
    N = len(data)

    X = pd.DataFrame(index=range(2*N), columns=data.positive.columns)
    y = pd.DataFrame(np.zeros(2 * N), columns=['label'])

    for i in range(N):
        x_pos = data.positive.iloc[i].values
        x_neg = data.negative.iloc[i].values

        X.iloc[i] = x_pos - x_neg
        y.iloc[i] = 1

        X.iloc[i + N] = x_neg - x_pos
        y.iloc[i + N] = 0

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
    pca = PCA(n_components=2)
    fitted = pd.DataFrame(pca.fit_transform(X))

    fitted[2] = y
    fitted.columns = ['x1', 'x2', 'label']

    sns.lmplot(data=fitted, x='x1', y='x2', fit_reg=False, hue='label')
    plt.show()

if __name__ == '__main__':

    data = data_util.load_data()

    train_data, dev_data, _ = data_util.split_dataset(data)

    X_train, y_train = prepare_data(train_data)
    X_dev, y_dev = prepare_data(dev_data)

    learn_weights(X_train, y_train, X_dev, y_dev)

    plot_data(X_train, y_train)
