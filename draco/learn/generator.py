import json
import os

from draco.learn import data_util
from draco.spec import *

from draco import spec

def sample_partial_specs(specs):
    """ Given a list of full specs, sample partial specs from them 
    Args: 
        specs: full specs formed from (data, query) pairs, query is a vegalite json file
    Returns:
        a list of (data, partial_spec, spec) pairs, where the partial_spec is created from spec
    """
    results = []

    for entry in specs:
        data, query = entry[0], Query.from_vegalite(entry[1])
        partial_query = insert_holes(query)

        # re-run the insert function until we find a partial spec different from the input. 
        while partial_query.to_asp() == query.to_asp():
            partial_query = insert_holes(query)
        
        results.append((Task(data, partial_query), Task(data, query)))

    return results

def subst_w_prob(v1, v2, prob):
    return np.random.choice([v1, v2], p=[prob, 1. - prob])

def insert_holes(query, prob=0.8, subst_val=spec.HOLE):
    """ given a query, randomly substitute values to generate a partial spec
    Args: 
        query: a vegalite object
        prob: the probability to substitute an attribute in query with None
    Returns:
        a partial spec generated from the full spec
    """
    mark = subst_w_prob(query.mark, subst_val, prob)
    encodings = []
    for enc in query.encodings:
        channel = subst_w_prob(enc.channel, subst_val, prob)
        field = enc.field
        ty = subst_w_prob(enc.ty, subst_val, prob)
        aggregate = subst_w_prob(enc.aggregate, subst_val, prob)
        binning = subst_w_prob(enc.binning, subst_val, prob)
        log_scale = subst_w_prob(enc.log_scale, subst_val, prob)
        zero = subst_w_prob(enc.zero, subst_val, prob)
        encodings.append(Encoding(channel, field, ty, aggregate, binning, log_scale, zero, enc.id))
    return Query(mark, encodings)

if __name__ == '__main__':

    np.random.seed(1)

    specs = data_util.get_raw_data()
    results = sample_partial_specs(specs)

    cql_out_dir = os.path.join("..", "..", '__tmp__', 'cql_specs')
    if not os.path.exists(cql_out_dir):
        os.makedirs(cql_out_dir)

    vl_out_dir = os.path.join("..", "..", '__tmp__', 'vl_specs')
    if not os.path.exists(vl_out_dir):
        os.makedirs(vl_out_dir)

    for i, entry in enumerate(results):
        with open(os.path.join(cql_out_dir, f"cql_{i}.json"), "w") as f:
            json.dump(entry[0].to_compassql(), f, indent=4)

        with open(os.path.join(vl_out_dir, f"full_{i}.vl.json"), "w") as f:
            json.dump(entry[1].to_compassql(), f, indent=4)
        