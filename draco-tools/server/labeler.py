from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os

app = Flask(__name__)
CORS(app)

label_data_db = "label_data.db"

@app.route('/fetch_pair', methods=['GET'])
def fetch_pair():
    """ Fetch a pair from the server """
    with open(os.path.join(os.path.dirname(__file__), 'example.json')) as data:
        return jsonify(json.load(data))

@app.route('/upload_label', methods=['POST'])
def upload_label():
    """ upload a label to the server """
    if not request or not 'id' in request.json or not 'label' in request.json:
        abort(400)
    print(request.json)
    return 'success'


def load_unlabeled_data():
    with open(os.path.join(os.path.dirname(__file__), 'unlabeled.json')) as f:
        return json.load(data)['data']

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
