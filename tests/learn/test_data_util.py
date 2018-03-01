import os

import numpy as np
import pytest

from draco.learn.data_util import load_data, pickle_path


def test_load_data():
    if not os.path.isfile(pickle_path):
        pytest.skip('Test needs data file')

    train, test = load_data()

    size = len(train) + len(test)
    assert len(train) - int(0.7 * size) <= 1
    assert len(test) - int(0.3 * size) <= 1
