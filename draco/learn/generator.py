import json
import os

from draco.learn import data_util
from draco.spec import *

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
        
        results.append((data, partial_query, query))

    return results

def subst_w_prob(v1, v2, prob):
    return np.random.choice([v1, v2], p=[prob, 1. - prob])

def insert_holes(query, prob=0.8):
    """ given a query, randomly substitute values to generate a partial spec
    Args: 
        query: a vegalite object, 
        prob: the probability to substitute an attribute in query with None
    Returns:
        a partial spec generated from the full spec
    """
    mark = subst_w_prob(query.mark, None, prob)
    encodings = []
    for enc in query.encodings:
        channel = subst_w_prob(enc.channel, None, prob)
        field = enc.field
        ty = subst_w_prob(enc.ty, None, prob)
        aggregate = subst_w_prob(enc.aggregate, None, prob)
        binning = subst_w_prob(enc.binning, None, prob)
        log_scale = subst_w_prob(enc.log_scale, None, prob)
        zero = subst_w_prob(enc.zero, None, prob)
        encodings.append(Encoding(channel, field, ty, aggregate, binning, log_scale, zero, enc.id))
    return Query(mark, encodings)

if __name__ == '__main__':
    specs = data_util.get_raw_data()
    results = sample_partial_specs(specs)