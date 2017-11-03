import os
import io
from jsonschema import validate
import json
import pytest

from draco.run import run

EXAMPLES_DIR = os.path.join("examples")

class TestFull():
    @pytest.mark.skip(reason="validator doesn't work")
    def test_output_schema(self):
        json_files = [os.path.join(EXAMPLES_DIR, fname)
                      for fname in os.listdir(EXAMPLES_DIR) if fname.endswith(".json")]
        for fname in json_files:
            with open(fname, "r") as f, io.StringIO() as out:
                run(f, out, tmp_dir="__tmp__", draco_lp_dir="asp")
                content = str(out.getvalue())
                with open("node_modules/vega-lite/build/vega-lite-schema.json", "r") as f_schema:
                    validate(json.loads(content), json.load(f_schema))
