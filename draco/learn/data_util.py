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

pickle_path = absolute_path('../../__tmp__/data.pickle')
man_data_path = absolute_path('../../data/training/manual.json')
yh_data_path = absolute_path('../../data/training/younghoon.json')
ba_data_path = absolute_path('../../data/training/bahador.json')
compassql_data_path = absolute_path('../../data/compassql_examples')
data_dir = absolute_path('../../data/') # the dir containing data used in visualization

halden_data_path = absolute_path('../../data/to_label')


PosNegExample = namedtuple('PosNeg', ['pair_id', 'data', 'task', 'source', 'negative', 'positive'])


def load_neg_pos_data() -> List[PosNegExample]:
    raw_data = []
    i = 0

    for path in [man_data_path, yh_data_path, ba_data_path]:
        with open(path) as f:
            json_data = json.load(f)

            for row in json_data['data']:
                fields = list(map(Field.from_obj, row['fields']))
                spec_schema = Data(fields, row.get('num_rows'))
                raw_data.append(PosNegExample(
                    i,
                    spec_schema,
                    row.get('task'),
                    json_data['source'],
                    row['negative'],
                    row['positive'])
                )

                i += 1

    return raw_data


def load_partial_full_data(path=compassql_data_path, data_dir=data_dir):
    ''' load partial-full spec pairs from the directory
        Args:
            compassql_data_dir: the directory containing compassql data with
                 'input' and 'output' directories specifying compassql input and output
        Returns:
            A dictionary mapping each case name into a pair of partial spec - full spec.
    '''

    def load_spec(input_dir, data_dir, format):
        ''' load compassql data
            Args: input_dir: the directory containing a set of json compassql specs
                  format: one of 'compassql' and 'vegalite'
            Returns:
                a dictionary containing name and the Task object representing the spec
        '''
        files = [os.path.join(input_dir, f) for f in os.listdir(input_dir)]
        result = {}
        for fname in files:
            if not fname.endswith('.json'):
                continue
            with open(fname, 'r') as f:
                content = json.load(f)
                if 'url' in content['data'] and content['data']['url'] is not None:
                    content['data']['url'] = os.path.join(data_dir, os.path.basename(content['data']['url']))
                if format == 'compassql':
                    spec = Task.from_cql(content, '.')
                elif format == 'vegalite':
                    spec = Task.from_vegalite(content)
                result[os.path.basename(fname)] = spec
        return result

    partial_specs = load_spec(os.path.join(path, 'input'), data_dir, 'compassql')
    compassql_outs = load_spec(os.path.join(path, 'output'), data_dir, 'vegalite')

    result = {}
    for k in partial_specs:
        result[k] = (partial_specs[k], compassql_outs[k])
    return result


def load_halden_data(include_features=True, data_dir=data_dir):
    ''' load halden's data into memory the result is a list of unlabeled pairs
        Returns:
            A generator yielding entires one at a time
    '''

    files = [os.path.join(halden_data_path, f)
                for f in os.listdir(halden_data_path)
                if f.endswith('.json')]

    data_cache = {}
    def acquire_data(url):
        if url not in data_cache:
            data_cache[url] = Data.from_json(os.path.join(data_dir, os.path.basename(url)))
            # set the url to short name, since the one above set it to full name in the current machine
            data_cache[url].url = url
        return data_cache[url]

    spec_to_task = lambda spec: Task(acquire_data(spec["data"]["url"]), Query.from_vegalite(spec), spec["task"] if "task" in spec else "value")

    pair_process_func = lambda p: {"source": f"halden",
                                   "task": p[0]["spec"]["task"] if "task" in p[0]["spec"] else "value",
                                   "left": p[0]["spec"],
                                   "right": p[1]["spec"],
                                   "left_feature": p[0]["feature"],
                                   "right_feature": p[1]["feature"]}

    memoized_violations = {}

    to_label_pairs = None
    for fname in files:
        with open(fname, 'r') as f:
            content = json.load(f)
            for num_channel in content:
                for spec_list in content[num_channel]:

                    task_list = [spec_to_task(spec) for spec in spec_list]

                    if include_features:
                        features = [violation_dict_to_vec(
                                        count_violations_memoized(memoized_violations, task))
                                    for task in task_list]
                        #features = tasks_to_vec([spec_to_task(spec) for spec in spec_list])
                    else:
                        features = [None for task in task_list]

                    #print(spec_list[0]["data"])
                    #print(len(spec_list))
                    #print(len(features))

                    #for i in range(len(spec_list)):
                    #    print(spec_list[i])
                    #    print(tasks_to_vec([spec_to_task(spec_list[0])])[0])
                    #    print(features[i])

                    specs_and_features = [{"spec": task_list[i].to_vegalite(), "feature": features[i]} for i in range(len(task_list))]

                    for pair in map(pair_process_func, itertools.combinations(specs_and_features, 2)):
                        yield pair


def count_violations_memoized(processed_specs: Dict[str, Dict], task: Task):
    key = task.to_asp()
    if key not in processed_specs:
        processed_specs[key] = count_violations(task)
    return processed_specs[key]


def violation_dict_to_vec(violation_dict):
    # convert dict format violation result into a vector
    feature_names = get_feature_names()
    vec = [violation_dict[name] if name in violation_dict else 0 for name in feature_names]
    return vec

def get_nested_index():
    '''
    Gives you a nested pandas index that we apply to the data when creating a dataframe.
    '''
    features = get_feature_names()

    iterables = [['negative', 'positive'], features]
    index = pd.MultiIndex.from_product(iterables, names=['category', 'feature'])
    index.append(pd.MultiIndex.from_arrays([['source', 'task'], ['', '']]))
    return index


def get_feature_names():
    weights = current_weights()
    features = list(map(lambda s: s[:-len('_weight')], weights.keys()))

    return features


def pair_partition_to_vec(input_data: Tuple[Dict, Iterable[Union[PosNegExample, np.ndarray]]]):
    processed_specs, partiton_data = input_data

    df = pd.DataFrame(columns=get_nested_index())

    for example in partiton_data:
        Encoding.encoding_cnt = 0

        if isinstance(example, np.ndarray):
            example = PosNegExample(*example)

        neg_feature_vec = count_violations_memoized(processed_specs,
                            Task(example.data, Query.from_vegalite(example.negative), example.task))
        pos_feature_vec = count_violations_memoized(processed_specs,
                            Task(example.data, Query.from_vegalite(example.positive), example.task))

        # Reformat the json data so that we can insert it into a multi index data frame.
        # https://stackoverflow.com/questions/24988131/nested-dictionary-to-multiindex-dataframe-where-dictionary-keys-are-column-label
        specs = {('negative', key): values for key, values in neg_feature_vec.items()}
        specs.update({('positive', key): values for key, values in pos_feature_vec.items()})

        specs[('source', '')] = example.source
        specs[('task', '')] = example.task

        df = df.append(pd.DataFrame(specs, index=[example.pair_id]))  # the idx is the same as the one in load_neg_pos_data

    return df


def task_partition_to_vec(input_data: Tuple[Dict, Iterable[Tuple[int, Task]]]):
    processed_specs, partiton_data = input_data

    df = pd.DataFrame(columns=get_feature_names())

    for idx, task in partiton_data:
        Encoding.encoding_cnt = 0

        vec = count_violations_memoized(processed_specs, task)

        df = df.append(pd.DataFrame(vec, index=[idx]))

    return df


def run_in_parallel(func, data: List[Any]) -> pd.DataFrame:
    ''' Like map, but parallel. '''

    splits = min([cpu_count() * 20, math.ceil(len(data) / 10)])
    df_split = np.array_split(data, splits)
    processes = min(cpu_count(), splits)

    logger.info(f'Running {splits} partitions of {len(data)} items in parallel on {processes} processes.')

    with Manager() as manager:
        m: Any = manager  # fix for mypy
        d = m.dict()  # shared dict for memoization
        pool = m.Pool(processes=processes)
        df = pd.concat(pool.map(func, list(map(lambda s: (d,s), df_split))))
        pool.close()
        pool.join()

    df = df.sort_index()

    logger.info(f'Hash of dataframe: {hash_pandas_object(df).sum()}')

    return df


def pairs_to_vec(neg_pos_data: List[PosNegExample]) -> pd.DataFrame:
    ''' given neg_pos_data, convert them into feature vectors. '''

    return run_in_parallel(pair_partition_to_vec, neg_pos_data)


def tasks_to_vec(specs: List[Task]) -> pd.DataFrame:
    ''' Turn a list of tasks into a feature vecor. '''
    return run_in_parallel(task_partition_to_vec, list(enumerate(specs)))


def get_pos_neg_data() -> pd.DataFrame:
    '''
    Load data created with `generate_and_store_data`.
    '''
    data = pd.read_pickle(pickle_path)
    data.fillna(0, inplace=True)

    return data


def load_data(test_size: float=0.3, random_state=1) -> Tuple[pd.DataFrame, pd.DataFrame]:
    '''
        Returns:
            a tuple containing: train_dev, test.
    '''
    data = get_pos_neg_data()
    return train_test_split(data, test_size=test_size, random_state=random_state)


if __name__ == '__main__':
    ''' Generate and store data in default path. '''
    neg_pos_data = load_neg_pos_data()
    data = pairs_to_vec(neg_pos_data)
    data.to_pickle(pickle_path)
