import json
import os
import numpy as np

from draco.learn import data_util
from draco.spec import *

import pathlib
import sqlite3

def init_database(db_file):

    if pathlib.Path(db_file).exists():
        print("[Err] The database {} exists, won't create one.".format(db_file))
        return

    conn = sqlite3.connect(db_file)
    c = conn.cursor()

    # Create table
    c.execute('CREATE TABLE unlabeled (id text primary key, left text, right text)')
    c.execute("CREATE TABLE labels (id text, label integer)")

    input_pairs = data_util.load_neg_pos_data()

    for i, entry in enumerate(input_pairs):

        if entry.source != "younghoon":
            continue

        data = entry.data
        task = entry.task

        data.fill_with_random_content()

        if np.random.choice([True, False]):
            q1 = Query.from_vegalite(entry.positive)
            q2 = Query.from_vegalite(entry.negative)
        else:
            q1 = Query.from_vegalite(entry.negative)
            q2 = Query.from_vegalite(entry.positive)

        tid = f"{entry.source}-{i}"
        t1 = Task(data, q1, task)
        t2 = Task(data, q2, task)

        print(tid)

        stmt = "INSERT INTO unlabeled VALUES (?, ?, ?)"

        c.execute(stmt, (tid, t1.to_vegalite_json(), t2.to_vegalite_json()))

        conn.commit()
    
    conn.close()


if __name__ == '__main__':
    init_database("label_data.db")