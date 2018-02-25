from pprint import pprint

import numpy as np

from draco.learn import data_util, linear
from draco.learn.helper import current_weights
from draco.run import run


def play(partial_full_data):

    train_dev, _  = data_util.load_data()
    X, y = linear.prepare_data(train_dev)

    clf = linear.train_model(X, y)

    # columns where all X[i] are zero
    unused_features = np.nonzero(np.sum(np.abs(X), axis=0) == 0)[0]
    # if a feature is not used, its weight is 0
    learnt_weights = [int(x * 1000) if (i not in unused_features) else None
                      for i, x in enumerate(clf.coef_[0])]

    init_weights = current_weights()

    weights = {}
    for i, k in enumerate(init_weights):
        if learnt_weights[i] is not None:
            weights[k] = learnt_weights[i]
        else:
            weights[k] = 10000 + init_weights[k]

    for case in partial_full_data:
        partial_spec, full_spec = partial_full_data[case]
        draco_rec = run(partial_spec, constants=weights, silence_warnings=True)

        print(draco_rec.to_vegalite_json())
        print(full_spec.to_vegalite_json())
        print("======================")


if __name__ == '__main__':
    play(data_util.load_partial_full_data())
