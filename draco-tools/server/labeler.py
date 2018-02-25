from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os


app = Flask(__name__)
CORS(app)

@app.route('/pair', methods=['GET'])
def get_pair():
    with open(os.path.join(os.path.dirname(__file__), 'example.json')) as data:
        return jsonify(json.load(data))

@app.route('/pair', methods=['POST'])
def choose():
    if not request or not 'id' in request.json or not 'label' in request.json:
        abort(400)
    print(request.json)
    return 'success'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
