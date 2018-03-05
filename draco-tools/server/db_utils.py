import json
import os
import pathlib
import sqlite3
from typing import Dict

import numpy as np

from draco.learn import data_util
from draco.spec import Query, Task


def create_database(db_file):
    ' initialize the databsae and insert default entries into it. '

    if pathlib.Path(db_file).exists():
        print('[Err] The database {} exists, won\'t create one.'.format(db_file))
        return

    conn = sqlite3.connect(db_file)
    c = conn.cursor()

    # Create table
    c.execute('''CREATE TABLE pairs (id text primary key, task text, left text, right text,
                                         left_feature text, right_feature text)''')
    c.execute('CREATE TABLE labels (id text, label integer)')

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

        print(tid + task)

        stmt = 'INSERT INTO pairs VALUES (?, ?, ?, ?, ?, ?)'

        c.execute(stmt, (tid, task, t1.to_vegalite_json(), t2.to_vegalite_json(),
                         json.dumps(vec1), json.dumps(vec2)))

        conn.commit()

    conn.close()


def load_labeled_specs(db_file):
    """ load all pairs have been labeled
        Args: the database file containing corresponding entries
        Returns:
            A list of object files containing pairs and their labels,
            in the form of {
                "id": xx,
                "label": xx,
                "left_spec": xx, //dict obj represented spec
                "right_spec": xx, // dict obj represented spec
                "left_feature": xx,
                "right_feature": xx
            }
    """

    conn = sqlite3.connect(db_file)
    c = conn.cursor()

    c.execute('''SELECT pairs.id,
                        labels.label,
                        pairs.left,
                        pairs.right,
                        pairs.left_feature,
                        pairs.right_feature
                 FROM labels JOIN pairs
                 WHERE labels.id = pairs.id''')

    label_and_features = c.fetchall()

    return [{
        "id": r[0],
        "label": r[1],
        "left_spec": json.loads(r[2]),
        "right_spec": json.loads(r[3]),
        "left_feature": json.loads(r[4]),
        "right_feature": json.loads(r[5])
    } for r in label_and_features]


if __name__ == '__main__':
    db_file = os.path.join(os.path.dirname(__file__), 'label_data.db')
    create_database(db_file)
    insert_user_study_data(db_file)
    labeled = load_labeled_specs(db_file)
