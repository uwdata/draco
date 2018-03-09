from flask import Flask, jsonify, request, g
from flask_cors import CORS

import json
import numpy as np
import os
from draco.learn import data_util

import sqlite3

app = Flask(__name__)
CORS(app)

DATABASE = os.path.join(os.path.dirname(__file__), 'label_data.db')

# not thread safe, not process safe
global_state = {
    "db": None,
    "lev_scores": None,
    "unlabeled": None,
    "features": None
}


def get_db():
    db = global_state["db"]
    if db is None:
        print("connect to db")
        global_state["db"] = sqlite3.connect(DATABASE)
        db = global_state["db"]
    return db


def get_features():
    features = global_state["features"]
    if features is None:
        _, features = data_util.get_unlabeled_data()
        global_state["features"] = features
    return features


def get_leverage_score():
    """ get leverage score """

    lev_scores = global_state["lev_scores"]
    
    features = get_features()

    if lev_scores is None:

        print("calculating lev scores")

        X = features.negative - features.positive

        u, s, vh = np.linalg.svd(X, full_matrices=False)

        raw_lev_scores = list((np.sum(u*u, 1) * 1000))

        lev_scores = {}

        for i, key in enumerate(list(X.index)):
            lev_scores[key] = raw_lev_scores[i]

        global_state["lev_scores"] = lev_scores

    return lev_scores


def get_unlabeled_data():
    """ load unlabeled data into memory """

    # todo: optimize this process is necessary

    unlabeled_pairs = global_state["unlabeled"]

    if unlabeled_pairs is None:

        print("fetching unlabeled data...")

        db = get_db()
        c = db.cursor()

        c.execute('''SELECT pairs.id, pairs.source, pairs.task, pairs.left, pairs.right
                     FROM pairs
                     WHERE NOT EXISTS (SELECT id FROM labels WHERE labels.id = pairs.id)''')

        content = c.fetchall()

        result = {}
        for row in content:
            pair_id = row[0]
            data = {
                "id": row[0],
                "source": row[1],
                "task": row[2],
                "left": json.loads(row[3]),
                "right": json.loads(row[4])
            }
        
            result[row[0]] = data

        unlabeled_pairs = global_state["unlabeled"] = result

    return unlabeled_pairs


@app.route('/backdoor', methods=['GET'])
def backdoor():
    """ something will happen... """
    lev_score = get_leverage_score()
    return jsonify(lev_score)


@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()


@app.route('/fetch_pair', methods=['GET'])
def fetch_pair():
    """ fetch an unlabeled pair from the server """

    num_pairs = request.args.get('num_pairs', default=1, type=int)
    unlabeled_data = get_unlabeled_data()

    mode = np.random.choice([0, 1], p=[0.9, 0.1])
    id_list = list(unlabeled_data.keys())

    if mode == 0:
        # sampling randomly
        rand_indices = np.random.choice(id_list, size=num_pairs, replace=False)
    elif mode == 1:
        # sampling base on leverage scores
        lev_scores = get_leverage_score()
        probs = np.array([lev_scores[key] for key in id_list])
        probs = probs / np.sum(probs)
        rand_indices = np.random.choice(id_list, size=num_pairs, replace=False, p=probs)

    return jsonify([unlabeled_data[i] for i in rand_indices])


@app.route('/upload_label', methods=['POST'])
def upload_label():
    """ upload a label to the server """
    if not request or not 'id' in request.json or not 'label' in request.json:
        abort(400)

    # get user / a string
    if not 'user' in request.json:
        user = 'anonymous'
    else:
        user = request.json['user']

    db = get_db()
    c = db.cursor()

    pair_id = request.json['id']
    label = request.json['label']

    stmt = "INSERT INTO labels VALUES (?, ?, ?)"
    c.execute(stmt, (pair_id, label, user))

    db.commit()

    # update the in memory copy
    get_unlabeled_data().pop(pair_id, None)

    print(f"[OK] Insert pair {pair_id} with label {label} by user {user}.")

    return 'success'


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', threaded=False, processes=1)
