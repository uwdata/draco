import json
import logging
import os

import numpy as np

from draco.learn import data_util, linear
from draco.learn.helper import current_weights
from draco.run import run
from draco.spec import Task


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(__file__), p)


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

    pairs = generate_visual_pairs(partial_full_data, weights)

    if output_file is not None:
        with open(output_file, "w+") as f:
            print(f'Writing pairs to {output_file}')
            json.dump(pairs, f)
    else:
        print(json.dumps(pairs))


def generate_visual_pairs(partial_full_data, weights):
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

        draco_rec = run(Task.from_cql(partial_spec), constants=weights)

        if draco_rec is None:
            logger.warning(f'Could not find a spec for {partial_spec}')

            result["specs"].append({
                "first": None,
                "second": full_spec,
                "properties": {
                    "input": partial_spec
                }
            })

            continue

        result["specs"].append({
            "first": draco_rec.to_vegalite(),
            "second": full_spec,
            "properties": {
                "input": partial_spec
            }
        })

    return result


if __name__ == '__main__':
    # spec_dir = absolute_path("../../data/synthetic")
    # dataset = data_util.load_partial_full_data(spec_dir)
    # output_file = absolute_path("../../data/spec_pairs/synthetic.json")
    # play(dataset, train_weights=True, output_file=output_file)

    # spec_dir = absolute_path("../../data/synthetic")
    # dataset = data_util.load_partial_full_data(spec_dir)
    # output_file = absolute_path("../../data/spec_pairs/synthetic_default_weights.json")
    # play(dataset, train_weights=False, output_file=output_file)

    # spec_dir = absolute_path("../../data/compassql_examples")
    # dataset = data_util.load_partial_full_data(spec_dir)
    # output_file = absolute_path("../../data/spec_pairs/draco_cql.json")
    # play(dataset, train_weights=True, output_file=output_file)

    spec_dir = absolute_path("../../data/compassql_examples")
    dataset = data_util.load_partial_full_data(spec_dir)
    output_file = absolute_path("../../data/spec_pairs/draco_cql_default_weights.json")
    play(dataset, train_weights=False, output_file=output_file)
    # open `http://localhost:3000/specviewer?data=spec_pairs/draco_cql_default_weights.json`
