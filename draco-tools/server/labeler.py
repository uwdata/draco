from flask import Flask, jsonify, request, g
from flask_cors import CORS

import json
import numpy as np
import os

import sqlite3

app = Flask(__name__)
CORS(app)

lock = Lock()

DATABASE = os.path.join(os.path.dirname(__file__), 'label_data.db')

# not thread safe, not process safe
global_state = {
    "db": None,
    "lev_scores": None,
    "unlabeled": None
}

def get_db():
    db = global_state["db"]
    if db is None:
        print("connect to db")
        global_state["db"] = sqlite3.connect(DATABASE)
        db = global_state["db"]
    return db

def get_leverage_score():
    """ get leverage score """

    lev_scores = global_state["lev_scores"]

    if lev_scores is None:

        print("calculating lev scores")

        db = get_db()
        c = db.cursor()

        c.execute('''SELECT pairs.id, pairs.left_feature, pairs.right_feature 
                     FROM pairs''')

        content = c.fetchall()

        keys = []
        vecs = []

        for row in content:
            keys.append(row[0])
            vec1 = json.loads(row[1])
            vec2 = json.loads(row[2])
            vecs.append(np.array(vec1) - np.array(vec2))

        X = np.array(vecs)

        u, s, vh = np.linalg.svd(X, full_matrices=False)

        raw_lev_scores = (np.sum(u*u, 1) * 1000).tolist()

        lev_scores = {}
        for i, key in enumerate(keys):
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

        c.execute('''SELECT pairs.id, pairs.task, pairs.left, pairs.right, 
                            pairs.left_feature, pairs.right_feature 
                     FROM pairs
                     WHERE NOT EXISTS (SELECT id FROM labels WHERE labels.id = pairs.id)''')

        content = c.fetchall()

        result = {}
        for row in content:
            data = {
                "id": row[0],
                "task": row[1],
                "left": json.loads(row[2]),
                "right": json.loads(row[3]),
                "left_feature": json.loads(row[4]),
                "right_feature": json.loads(row[5])
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

    mode = np.random.choice([0, 1])
    id_list = list(unlabeled_data.keys())

    if mode == 2:
        # sampling randomly
        rand_indices = np.random.choice(id_list, size=num_pairs, replace=False)
    elif mode == 0 or mode == 1:
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

    db = get_db()
    c = db.cursor()

    tid = request.json['id']
    label = 0 if request.json['label'] == '=' else (-1 if request.json['label'] == '<' else 1)

    stmt = "INSERT INTO labels VALUES (?, ?)"
    c.execute(stmt, (tid, label))

    db.commit()

    # update the in memory copy
    get_unlabeled_data().pop(tid, None)

    return 'success'


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', threaded=False)
