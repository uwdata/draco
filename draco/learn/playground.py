import numpy as np

from draco.learn import data_util
from draco.learn import linear
from draco.learn.helper import *

from pprint import pprint

def play(partial_full_data):

    train_dev, _  = data_util.load_data()
    X, y = linear.prepare_data(train_dev)

    #return train_and_plot(X, y)
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
    partial_full_data = data_util.load_partial_full_data()
    play(partial_full_data)
    


    