import os
import json
from jsonschema import validate

from draco.run import run

EXAMPLES_DIR = os.path.join("examples")

class TestFull():
    def test_output_schema(self):
        json_files = [os.path.join(EXAMPLES_DIR, fname)
                      for fname in os.listdir(EXAMPLES_DIR) if fname.endswith(".json")]

        with open("node_modules/vega-lite/build/vega-lite-schema.json") as sf:
            schema = json.load(sf)

            for fname in json_files:
                with open(fname, "r") as f:
                    task = run(f)
                    validate(task.to_vegalite_obj(), schema)
