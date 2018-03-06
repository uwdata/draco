import numpy as np

from draco.learn import data_util, linear
from draco.learn.helper import current_weights
from draco.run import run

import os

import json

def play(partial_full_data, train_weights=True, output_file=None):
    
    init_weights = current_weights()

    if train_weights:
        train_dev, _  = data_util.load_data()

        X = train_dev.positive - train_dev.negative
        clf = linear.train_model(X)

        # columns where all X[i] are zero
        unused_features = np.nonzero(np.sum(np.abs(X), axis=0) == 0)[0]
        # if a feature is not used, its weight is 0
        learnt_weights = [int(x * 1000) if (i not in unused_features) else None
                          for i, x in enumerate(clf.coef_[0])]

        weights = {}
        for i, k in enumerate(init_weights):
            if learnt_weights[i] is not None:
                weights[k] = learnt_weights[i]
            else:
                weights[k] = 10000 + init_weights[k]
    else:
        weights = init_weights

    pairs = generate_visaul_pairs(partial_full_data, weights)

    if output_file is not None:
        with open(output_file, "w+") as f:
            json.dump(pairs, f)
    else:
        print(json.dumps(pairs))


def generate_visaul_pairs(partial_full_data, weights):
    # Generate pairs that can be visualized by bug finders
    result = {}
    result["headers"] = {
        "first": {
            "title": "Draco",
            "subtitle": "Draco Prediction"
        },
        "second": {
            "title": "CQL",
            "subtitle": "Compassql Prediction"
        }
    }

    result["specs"] = []
    for case in partial_full_data:
        partial_spec, full_spec = partial_full_data[case]

        draco_rec = run(partial_spec, constants=weights)

        if draco_rec is None:
            continue

        if len(result) > 15:
            break

        if draco_rec.data.url is not None:
            data_url = os.path.join("data", os.path.split(draco_rec.data.url)[1])

            draco_rec.data.url = data_url
            full_spec.data.url = data_url

        result["specs"].append({
            "first": draco_rec.to_vegalite(),
            "second": full_spec.to_vegalite(),
            "properties": {}
        })

    return result


if __name__ == '__main__':
    import logging
    logging.basicConfig()
    logging.getLogger().setLevel(logging.WARN)

    spec_dir = os.path.join(os.path.dirname(__file__), "../../data/synthetic")
    output_file = os.path.join(os.path.dirname(__file__), "../../data/spec_pairs/synthetic.json")
    #output_file = os.path.join(os.path.dirname(__file__), "../../data/spec_pairs/synthetic_default_weights.json")

    #spec_dir = os.path.join(os.path.dirname(__file__), "../../data/compassql_examples")
    #output_file = os.path.join(os.path.dirname(__file__), "../../data/spec_pairs/draco_cql.json")
    #output_file = os.path.join(os.path.dirname(__file__), "../../data/spec_pairs/draco_cql_default_weights.json")

    dataset = data_util.load_partial_full_data(spec_dir)

    play(dataset, train_weights=True, output_file=output_file)


