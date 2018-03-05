import json
import os
import pathlib
import sqlite3
from typing import Dict

import numpy as np

from draco.learn import data_util
from draco.spec import Query, Task


def init_database(db_file):
    ' initialize the databsae and insert default entries into it. '

    if pathlib.Path(db_file).exists():
        print('[Err] The database {} exists, won\'t create one.'.format(db_file))
        return

    conn = sqlite3.connect(db_file)
    c = conn.cursor()

    # Create table
    c.execute('CREATE TABLE unlabeled (id text primary key, left text, right text)')
    c.execute('CREATE TABLE labels (id text, label integer)')
    c.execute('CREATE TABLE feature_vec (spec text, feature text)')

    conn.close()


def insert_user_study_data(db_file):

    # generate feature vector and store in database
    processed_specs: Dict = {}

    conn = sqlite3.connect(db_file)
    c = conn.cursor()

    input_pairs = data_util.load_neg_pos_data()

    for i, entry in enumerate(input_pairs):

        if entry.source != 'younghoon':
            continue

        data = entry.data
        task = entry.task

        data.fill_with_random_content()

        def query_and_features(spec):
            query = Query.from_vegalite(spec)
            t = Task(data, query, task)
            f = data_util.count_violations_memoized(processed_specs, t)
            return f, t

        if np.random.choice([True, False]):
            vec1, t1 = query_and_features(entry.positive)
            vec2, t2 = query_and_features(entry.negative)
        else:
            vec1, t1 = query_and_features(entry.negative)
            vec2, t2 = query_and_features(entry.positive)

        tid = f'{entry.source}-{i}'


        print(tid)

        stmt = 'INSERT INTO unlabeled VALUES (?, ?, ?)'

        c.execute(stmt, (tid, t1.to_vegalite_json(), t2.to_vegalite_json()))

        fv_stmt = 'INSERT INTO feature_vec VALUES (?, ?)'

        c.execute(fv_stmt, (t1.to_vegalite_json(), json.dumps(vec1)))
        c.execute(fv_stmt, (t2.to_vegalite_json(), json.dumps(vec2)))

        conn.commit()

    conn.close()


if __name__ == '__main__':
    db_file = os.path.join(os.path.dirname(__file__), 'label_data.db')
    init_database(db_file)
    insert_user_study_data(db_file)
