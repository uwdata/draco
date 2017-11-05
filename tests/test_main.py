import os
import io
import json
import subprocess
import pytest

from draco.run import run

EXAMPLES_DIR = os.path.join("examples")

class TestFull():
    @pytest.mark.slow
    def test_output_schema(self, tmpdir):
        json_files = [os.path.join(EXAMPLES_DIR, fname)
                      for fname in os.listdir(EXAMPLES_DIR) if fname.endswith(".json")]
        temp_file = f"{tmpdir}/spec.vl.json"
        for fname in json_files:
            with open(fname, "r") as f, open(temp_file, "w+") as out:
                run(f, out, tmp_dir=tmpdir, draco_lp_dir="asp")
            subprocess.check_call(["npm", "run", "ajv", "--", "-s", "node_modules/vega-lite/build/vega-lite-schema.json", "-d", temp_file])
