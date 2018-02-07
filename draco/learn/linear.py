from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

from sklearn import svm
from sklearn.decomposition import PCA
from sklearn import linear_model

from draco.learn import data_util


def prepare_data(data: pd.DataFrame):
    N = len(data)

    X = np.zeros((2 * N, len(data.positive.columns)))
    y = np.zeros(2 * N)

    for i in range(N):
        x_pos = data.positive.iloc[i].values
        x_neg = data.negative.iloc[i].values

        X[i] = x_pos - x_neg
        y[i] = 1

        X[i + N] = x_neg - x_pos
        y[i + N] = 0

    return X, y

def plot_contours(ax, clf, xx, yy, **params):
    """Plot the decision boundaries for a classifier.

    Parameters
    ----------
    ax: matplotlib axes object
    clf: a classifier
    xx: meshgrid ndarray
    yy: meshgrid ndarray
    params: dictionary of params to pass to contourf, optional
    """
    Z = clf.predict(np.c_[xx.ravel(), yy.ravel()])
    Z = Z.reshape(xx.shape)
    out = ax.contourf(xx, yy, Z, **params)
    return out

def classify_and_plot(X, y, split=0.7):
    """ Reduce X, y into 2D using PCA and use SVM to classify them
        Then plot the decision boundary as well as raw data points
    """

    pca = PCA(n_components=2)
    X = pca.fit_transform(X)

    split_index = int(len(X) * split)

    #clf = linear_model.LogisticRegression()
    clf = svm.LinearSVC(C=1)
    #clf = svm.SVC(C=1)

    X_train, y_train, X_dev, y_dev = data_util.split_XY(X, y)

    clf.fit(X_train, y_train)

    print(clf.score(X_train, y_train))
    print(clf.score(X_dev, y_dev))

    # for plotting
    X0, X1 = X[:, 0], X[:, 1]
    xx, yy = make_meshgrid(X0, X1)

    f, ax = plt.subplots()
    plot_contours(ax, clf, xx, yy,
                  cmap=plt.cm.coolwarm, alpha=0.8)
    ax.scatter(X0, X1, c=y, cmap=plt.cm.coolwarm, s=20, edgecolors='k')
    ax.set_xlim(xx.min(), xx.max())
    ax.set_ylim(yy.min(), yy.max())
    ax.set_xlabel('X0')
    ax.set_ylabel('X1')
    ax.set_xticks(())
    ax.set_yticks(())

    plt.show()

    return clf


def make_meshgrid(x, y, h=.02):
    """Create a mesh of points to plot in

    Parameters
    ----------
    x: data to base x-axis meshgrid on
    y: data to base y-axis meshgrid on
    h: stepsize for meshgrid, optional

    Returns
    -------
    xx, yy : ndarray
    """
    x_min, x_max = x.min() - 1, x.max() + 1
    y_min, y_max = y.min() - 1, y.max() + 1
    xx, yy = np.meshgrid(np.arange(x_min, x_max, h),
                         np.arange(y_min, y_max, h))
    return xx, yy


def plot_data(X, y):
    pca = PCA(n_components=2)
    X_2d = pca.fit_transform(X)

    fitted = pd.DataFrame(X_2d)

    fitted[2] = y
    fitted.columns = ['x1', 'x2', 'label']

    sns.lmplot(data=fitted, x='x1', y='x2', fit_reg=False, hue='label')
    plt.show()


if __name__ == '__main__':

    data = data_util.load_data()

    train_dev, _ = data_util.split_dataset(data, ratio=0.7)

    X, y = prepare_data(train_dev)

    classify_and_plot(X, y)
