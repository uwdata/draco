import json
import os
import pathlib
import sqlite3
import sys
from typing import Dict

import numpy as np

from draco.learn import data_util
from draco.spec import Query, Task


def create_database(db_file: str):
    ''' initialize the databsae and insert default entries into it. '''
    conn = sqlite3.connect(db_file)
    c = conn.cursor()

    # Create table
    c.execute('''CREATE TABLE pairs (id text primary key, task text, left text, right text)''')
    c.execute('CREATE TABLE labels (id text, label integer, user_id integer)')

    conn.close()


def insert_unlabeled_data(db_file: str):
    # generate feature vector and store in database

    #conn = sqlite3.connect(db_file)
    #c = conn.cursor()

    specs, features = data_util.get_unlabeled_data()

    for key in specs:

        entry = specs[key]
        feature = features.loc[key]

        print(spec)
        print(vec)

        sys.exit(-1)

        pair_id = entry['pair_id']
        source = entry['source']
        task = entry['task']
        left_spec = entry['left']
        right_spec = entry['right']
        vec1 = feature['left_feature']
        vec2 = entry['right_feature']

        tid = f'{source}-{i}'

        print(tid + (task or 'No Task'))

        stmt = 'INSERT INTO pairs VALUES (?, ?, ?, ?, ?, ?)'

        c.execute(stmt, (tid, task, json.dumps(left_spec), json.dumps(right_spec),
                         json.dumps(vec1), json.dumps(vec2)))

        conn.commit()

    conn.close()


def load_labeled_specs(db_file: str):
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

    #if pathlib.Path(db_file).exists():
    #    print('[Err] The database {} exists, won\'t create one.'.format(db_file))
    #    sys.exit(-1)

    #create_database(db_file)
    # insert_user_study_data(db_file)
    insert_unlabeled_data(db_file)
    #labeled = load_labeled_specs(db_file)
