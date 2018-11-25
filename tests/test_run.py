import json
import os

from jsonschema import validate

from draco.run import run
from draco.helper import read_data_to_asp
from draco.js import cql2asp

EXAMPLES_DIR = os.path.join("examples")


class TestFull:
    def test_output_schema(self):
        json_files = [
            os.path.join(EXAMPLES_DIR, fname)
            for fname in os.listdir(EXAMPLES_DIR)
            if fname.endswith(".json") and not fname.endswith(".vl.json")
        ]

        with open("node_modules/vega-lite/build/vega-lite-schema.json") as sf:
            schema = json.load(sf)

            for fname in json_files:
                with open(fname, "r") as f:
                    query_spec = json.load(f)

                    data = None
                    if "url" in query_spec["data"]:
                        data = read_data_to_asp(
                            os.path.join(
                                os.path.dirname(f.name), query_spec["data"]["url"]
                            )
                        )
                    elif "values" in query_spec["data"]:
                        data = read_data_to_asp(query_spec["data"]["values"])
                    else:
                        raise Exception("no data found in spec")
                    print(data)
                    query = cql2asp(query_spec)
                    program = query + data
                    result = run(program)
                    validate(result.as_vl(), schema)
