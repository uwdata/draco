'''
Processing data for learning procedures.
'''

import itertools
import json
import logging
import math
import os
from collections import namedtuple
from multiprocessing import Manager, cpu_count
from typing import Any, Dict, Iterable, List, Tuple, Union

import numpy as np
import pandas as pd
from pandas.util import hash_pandas_object
from sklearn.model_selection import train_test_split

from draco.learn.helper import count_violations, current_weights
from draco.spec import Data, Encoding, Field, Query, Task

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(__file__), p)

pos_neg_pickle_path = absolute_path('../../__tmp__/pos_neg.pickle')
unlabeled_pickle_path = absolute_path('../../__tmp__/unlabeled.pickle')

man_data_path = absolute_path('../../data/training/manual.json')
yh_data_path = absolute_path('../../data/training/kim2018.json')
ba_data_path = absolute_path('../../data/training/saket2018.json')
label_data_path = absolute_path('../../data/training/labeler.json')
compassql_data_path = absolute_path('../../data/compassql_examples')
data_dir = absolute_path('../../data/') # the dir containing data used in visualization

halden_data_path = absolute_path('../../data/to_label')


PosNegExample = namedtuple('PosNeg', ['pair_id', 'data', 'task', 'source', 'negative', 'positive'])
UnlabeledExample = namedtuple('Unlabeled', ['pair_id', 'data', 'task', 'source', 'left', 'right'])


def load_neg_pos_specs() -> Dict[str, PosNegExample]:
    raw_data = {}

    for path in [man_data_path, yh_data_path, ba_data_path, label_data_path]:
        with open(path) as f:
            i = 0
            json_data = json.load(f)

            for row in json_data['data']:
                fields = list(map(Field.from_obj, row['fields']))
                spec_schema = Data(fields, row.get('num_rows'))
                src = json_data['source']

                key = f'{src}-{i}'
                raw_data[key] = PosNegExample(
                    key,
                    spec_schema,
                    row.get('task'),
                    src,
                    row['negative'],
                    row['positive']
                )

                i += 1

    return raw_data


def load_partial_full_data(path=compassql_data_path):
    ''' load partial-full spec pairs from the directory

        Returns a dictionary mapping each case name into a pair of partial spec - full spec.
    '''

    def load_spec(input_dir):
        files = [os.path.join(input_dir, f) for f in os.listdir(input_dir)]
        result = {}
        for fname in files:
            if fname.endswith('.json'):
                with open(fname, 'r') as f:
                    spec = json.load(f)
                    result[os.path.basename(fname)] = spec
        return result

    partial_specs = load_spec(os.path.join(path, 'input'))
    compassql_outs = load_spec(os.path.join(path, 'output'))

    result = {}
    for k in partial_specs:
        result[k] = (partial_specs[k], compassql_outs[k])
    return result


def load_unlabeled_specs() -> Dict[str, UnlabeledExample]:
    files = [os.path.join(halden_data_path, f)
                for f in os.listdir(halden_data_path)
                if f.endswith('.json')]

    data_cache: Dict[str, Data] = {}
    def acquire_data(url):
        if url not in data_cache:
            data_cache[url] = Data.from_json(os.path.join(data_dir, os.path.basename(url)))
            # set the url to short name, since the one above set it to full name in the current machine
            data_cache[url].url = url
        return data_cache[url]

    raw_data: Dict[str, UnlabeledExample] = {}

    cnt = 0

    for fname in files:
        with open(fname, 'r') as f:
            content = json.load(f)
            for num_channel in content:
                for i, spec_list in enumerate(content[num_channel]):
                    for left, right in itertools.combinations(spec_list, 2):
                        if left == right:
                            logger.warning(f'Found pair with the same content file:{os.path.basename(fname)} - num_channel:{num_channel} - group:{i}')
                            continue

                        assert left['data']['url'] == right['data']['url']

                        url = left["data"]["url"]

                        key = f'halden-{cnt}'
                        raw_data[key] = UnlabeledExample(
                            key,
                            acquire_data(url),
                            None,
                            'halden',
                            left,
                            right
                        )
                        cnt += 1

    return raw_data


def count_violations_memoized(processed_specs: Dict[str, Dict], task: Task):
    key = task.to_asp()
    if key not in processed_specs:
        violations = count_violations(task)
        if violations is not None:
            processed_specs[key] = violations
    return processed_specs[key]


def get_nested_index(fields = None):
    '''
    Gives you a nested pandas index that we apply to the data when creating a dataframe.
    '''
    features = get_feature_names()

    iterables = [fields or ['negative', 'positive'], features]
    index = pd.MultiIndex.from_product(iterables, names=['category', 'feature'])
    index = index.append(pd.MultiIndex.from_arrays([['source', 'task'], ['', '']]))
    return index


def get_feature_names():
    weights = current_weights()
    features = sorted(map(lambda s: s[:-len('_weight')], weights.keys()))

    return features


def pair_partition_to_vec(input_data: Tuple[Dict, Tuple[str,str], Iterable[Union[PosNegExample, UnlabeledExample, np.ndarray]]]):
    processed_specs, fields, partiton_data = input_data

    columns = get_nested_index(fields)
    dfs = []

    for example in partiton_data:
        Encoding.encoding_cnt = 0

        # hack to get named tuples to work in parallel
        if isinstance(example, np.ndarray):
            example = PosNegExample(*example)

        # use numbers because we odn't know the names here
        neg_feature_vec = count_violations_memoized(processed_specs,
                            Task(example.data, Query.from_vegalite(example[4]), example.task))
        pos_feature_vec = count_violations_memoized(processed_specs,
                            Task(example.data, Query.from_vegalite(example[5]), example.task))

        # Reformat the json data so that we can insert it into a multi index data frame.
        # https://stackoverflow.com/questions/24988131/nested-dictionary-to-multiindex-dataframe-where-dictionary-keys-are-column-label
        specs = {(fields[0], key): values for key, values in neg_feature_vec.items()}
        specs.update({(fields[1], key): values for key, values in pos_feature_vec.items()})

        specs[('source', '')] = example.source
        specs[('task', '')] = example.task

        dfs.append(pd.DataFrame(specs, columns=columns, index=[example.pair_id]))

    return pd.concat(dfs)


def run_in_parallel(func, data: List[Union[PosNegExample, UnlabeledExample]], fields: Tuple[str, str]) -> pd.DataFrame:
    ''' Like map, but parallel. '''

    splits = min([cpu_count() * 20, math.ceil(len(data) / 10)])
    df_split = np.array_split(data, splits)
    processes = min(cpu_count(), splits)

    logger.info(f'Running {splits} partitions of {len(data)} items in parallel on {processes} processes.')

    with Manager() as manager:
        m: Any = manager  # fix for mypy
        d = m.dict()  # shared dict for memoization
        pool = m.Pool(processes=processes)

        tuples: List[Tuple[Dict, Tuple[str, str], Any]] = []
        for s in df_split:
            # add some arguments
            tuples.append((d, fields, s))

        df = pd.concat(pool.map(func, tuples))
        pool.close()
        pool.join()

    df = df.sort_index()

    logger.info(f'Hash of dataframe: {hash_pandas_object(df).sum()}')

    return df


def pairs_to_vec(specs: List[Union[PosNegExample, UnlabeledExample]], fields: Tuple[str, str]) -> pd.DataFrame:
    ''' given specs, convert them into feature vectors. '''

    return run_in_parallel(pair_partition_to_vec, specs, fields)


def _get_pos_neg_data() -> pd.DataFrame:
    '''
    Internal function to load the feature vecors.
    '''
    data = pd.read_pickle(pos_neg_pickle_path)
    data.fillna(0, inplace=True)

    assert set(data.negative.columns) == set(get_feature_names()), 'Feature names do not match.'

    return data


def load_data(test_size: float=0.3, random_state=1) -> Tuple[pd.DataFrame, pd.DataFrame]:
    ''' Returns:
            a tuple containing: train_dev, test.
    '''
    data = _get_pos_neg_data()
    return train_test_split(data, test_size=test_size, random_state=random_state)



def get_labeled_data() -> Tuple[Dict[str, PosNegExample], pd.DataFrame]:
    specs = load_neg_pos_specs()
    vecs = _get_pos_neg_data()

    assert len(specs) == len(vecs)

    return specs, vecs


def get_unlabeled_data() -> Tuple[Dict[str, UnlabeledExample], pd.DataFrame]:
    specs = load_unlabeled_specs()


    vecs = pd.read_pickle(unlabeled_pickle_path)
    vecs.fillna(0, inplace=True)

    assert len(specs) == len(vecs)

    return specs, vecs


if __name__ == '__main__':
    ''' Generate and store vectors for labeled data in default path. '''
    # neg_pos_specs = load_neg_pos_specs()
    # neg_pos_data = pairs_to_vec(list(neg_pos_specs.values()), ('negative', 'positive'))
    # neg_pos_data.to_pickle(pos_neg_pickle_path)

    # TODO: uncomment when we use this
    unlabeled_specs = load_unlabeled_specs()
    unlabeled_data = pairs_to_vec(list(unlabeled_specs.values()), ('left', 'right'))
    unlabeled_data.to_pickle(unlabeled_pickle_path)
