import logging
import os

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.colors import ListedColormap
from sklearn import svm
from sklearn.decomposition import PCA
from sklearn.model_selection import train_test_split

from draco.learn import data_util

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def train_model(X: pd.DataFrame, test_size: float=0.3, C: float=1, quiet=False):
    """ Given features X and labels y, train a linear model to classify them
        Args:
            X: a N x M matrix, representing feature vectors
            y: a N vector, representing labels
            test_size: the fraction of test data
    """

    X_train, X_dev = train_test_split(X, test_size=test_size, random_state=1)

    if isinstance(X_train, pd.DataFrame):
        X_train = X_train.as_matrix()

    size = len(X_train)

    y_train = np.ones(size)

    # flip a few examples at random
    idx = np.ones(size, dtype=bool)
    idx[:int(size/2)] = False
    np.random.shuffle(idx)

    X_train[idx] = -X_train[idx]
    y_train[idx] = -y_train[idx]

    clf = svm.LinearSVC(C=C, fit_intercept=False)
    clf.fit(X_train, y_train)

    if not quiet:
        print("Train score: ", clf.score(X_train, y_train))
        if test_size > 0:
            print("Dev score: ", clf.score(X_dev, np.ones(len(X_dev))))

    return clf


def train_and_plot(data: pd.DataFrame, test_size: float=0.3):
    """ use SVM to classify them and then plot them after projecting X, y into 2D using PCA
    """
    X = data.negative - data.positive

    pca = PCA(n_components=2)
    X2 = pca.fit_transform(X)

    clf = train_model(X, test_size)

    # for plotting
    X0, X1 = X2[:, 0], X2[:, 1]
    xx, yy = make_meshgrid(X0, X1)

    cm_bright = ListedColormap(['#FF0000', '#0000FF'])

    f, ax = plt.subplots(figsize=(8,6))

    # predictions made by the model
    pred = clf.predict(X)

    correct = (pred > 0)

    plt.scatter(X0[correct], X1[correct], c='g', cmap=cm_bright, alpha=0.5, marker='>', label='correct')
    plt.scatter(X0[~correct], X1[~correct], c='r', cmap=cm_bright, alpha=0.5, marker='<', label='incorrect')

    ax.set_xlim(xx.min(), xx.max())
    ax.set_ylim(yy.min(), yy.max())

    ax.set_xlabel('X0')
    ax.set_ylabel('X1')

    ax.set_xticks(())
    ax.set_yticks(())

    plt.title("Predictions of Linear Model")

    plt.annotate(f'Score: {clf.score(X, np.ones(len(X))):.{5}}. N: {int(len(data))}', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

    plt.legend(loc='lower right')
    plt.axis("tight")

    plt.show()

    return clf


def project_and_plot(data: pd.DataFrame, test_size: float=0.3):
    """ Reduce X, y into 2D using PCA and use SVM to classify them
        Then plot the decision boundary as well as raw data points
    """
    X = data.negative - data.positive

    pca = PCA(n_components=2)
    X = pca.fit_transform(X)

    clf = train_model(X, test_size)

    # for plotting
    X0, X1 = X[:, 0], X[:, 1]
    xx, yy = make_meshgrid(X0, X1)

    cm_bright = ListedColormap(['#FF0000', '#0000FF'])

    f, ax = plt.subplots(figsize=(8,6))

    plot_contours(ax, clf, xx, yy)

    # predictions made by the model
    pred = clf.predict(X)

    correct = (pred > 0)

    plt.scatter(X0[correct], X1[correct], c='g', cmap=cm_bright, alpha=0.5, marker='>', label='correct')
    plt.scatter(X0[~correct], X1[~correct], c='r', cmap=cm_bright, alpha=0.5, marker='<', label='incorrect')

    ax.set_xlim(xx.min(), xx.max())
    ax.set_ylim(yy.min(), yy.max())

    ax.set_xlabel('X0')
    ax.set_ylabel('X1')

    ax.set_xticks(())
    ax.set_yticks(())

    plt.title("Predictions of Linear Model")

    plt.annotate(f'Score: {clf.score(X, np.ones(len(X))):.{5}}. N: {int(len(data))}', (0,0), (0, -20), xycoords='axes fraction', textcoords='offset points', va='top')

    plt.legend(loc='lower right')
    plt.axis("tight")

    plt.show()

    return clf


def plot_contours(ax, clf, xx, yy, **params):
    """Plot the decision boundaries for a classifier.
    Params:
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


def make_meshgrid(x, y, h=.01):
    """Create a mesh of points to plot in
    Params:
        x: data to base x-axis meshgrid on
        y: data to base y-axis meshgrid on
        h: stepsize for meshgrid, optional
    Returns:
        xx, yy : ndarray
    """
    x_min, x_max = x.min() - 1, x.max() + 1
    y_min, y_max = y.min() - 1, y.max() + 1
    xx, yy = np.meshgrid(np.arange(x_min, x_max, h),
                         np.arange(y_min, y_max, h))
    return xx, yy


def main():
    test_size = 0.3
    train_dev, _ = data_util.load_data(test_size=test_size)

    clf = train_and_plot(train_dev, test_size=test_size)
    features = train_dev.negative.columns

    path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../asp/weights_learned.lp'))

    with open(path, 'w') as f:
        f.write('% Generated with `python draco/learn/linear.py`.\n\n')

        for feature, weight in zip(features, clf.coef_[0]):
            f.write(f'#const {feature}_weight = {int(weight * 1000)}.\n')

    logger.info(f'Wrote model to {path}')

if __name__ == '__main__':
    main()
