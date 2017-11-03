import os
import io
import json
import subprocess

from draco.run import run

EXAMPLES_DIR = os.path.join("examples")
TMP_FILE = "__tmp__/spec.vl.json"

class TestFull():
    def test_output_schema(self):
        json_files = [os.path.join(EXAMPLES_DIR, fname)
                      for fname in os.listdir(EXAMPLES_DIR) if fname.endswith(".json")]
        for fname in json_files:
            with open(fname, "r") as f:
                # run(f, out, tmp_dir="__tmp__", draco_lp_dir="asp")
                subprocess.check_call(["npm", "run", "ajv", "--", "-s", "node_modules/vega-lite/build/vega-lite-schema.json", "-d", TMP_FILE])
