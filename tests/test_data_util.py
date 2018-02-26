import os

import numpy as np
import pytest

from draco.learn.data_util import (load_data, paired_train_test_split,
                                   pickle_path)


def test_paired_train_test_split():
    X = np.arange(10)
    y = np.array([0]*5 + [1]*5)

    _, _, y_train, y_test = paired_train_test_split(X, y, 0.4)

    assert np.sum(y_train) == 3
    assert np.sum(y_test) == 2

def test_load_data():
    if not os.path.isfile(pickle_path):
        pytest.skip('Test needs data file')

    train, test = load_data()

    size = len(train) + len(test)
    assert len(train) - int(0.7 * size) <= 1
    assert len(test) - int(0.3 * size) <= 1
