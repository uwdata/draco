import json
import os

from jsonschema import validate

from draco.run import run
from draco.spec import Task

EXAMPLES_DIR = os.path.join('examples')

class TestFull():
    def test_output_schema(self):
        json_files = [os.path.join(EXAMPLES_DIR, fname)
                      for fname in os.listdir(EXAMPLES_DIR) if fname.endswith('.json') and not fname.endswith('.vl.json')]

        with open('node_modules/vega-lite/build/vega-lite-schema.json') as sf:
            schema = json.load(sf)

            for fname in json_files:
                print(">>>>>>>>")
                print(fname)
                
                with open(fname, 'r') as f:
                    query_spec = json.load(f)
                    print(query_spec)
                    input_task = Task.from_cql(query_spec, os.path.dirname(f.name))
                    print(input_task.to_asp())
                    task = run(input_task)
                    print(query_spec)
                    print(task)
                    validate(task.to_vegalite(), schema)
                print("<<<<<<<")
