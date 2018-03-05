from flask import Flask, jsonify, request, g
from flask_cors import CORS

import json
import os

import sqlite3

app = Flask(__name__)
CORS(app)

DATABASE = os.path.join(os.path.dirname(__file__), 'label_data.db')

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
    return db


@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()


@app.route('/fetch_pair', methods=['GET'])
def fetch_pair():
    """ fetch an unlabeled pair from the server """
    db = get_db()
    c = db.cursor()

    c.execute('''SELECT pairs.id, pairs.task, pairs.left, pairs.right 
                 FROM pairs
                 WHERE NOT EXISTS (SELECT id FROM labels WHERE labels.id = pairs.id)
                 ORDER BY pairs.id ASC LIMIT 1''')

    row = c.fetchone()

    data = {
        "id": row[0],
        "task": row[1],
        "left": json.loads(row[2]),
        "right": json.loads(row[3])
    }

    return jsonify(data)


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
    return 'success'


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
