import os
import json
from jsonschema import validate

from draco.run import run, build_args

EXAMPLES_DIR = os.path.join("examples")

class TestFull():
    def test_output_schema(self, tmpdir):
        json_files = [os.path.join(EXAMPLES_DIR, fname)
                      for fname in os.listdir(EXAMPLES_DIR) if fname.endswith(".json")]

        with open("node_modules/vega-lite/build/vega-lite-schema.json") as sf:
            schema = json.load(sf)

            for fname in json_files:
                with open(fname, "r") as f:
                    task = run(f, tmp_dir=tmpdir, draco_lp_dir="asp")
                    validate(task.to_vegalite_obj(), schema)

class TestBuildArgs():
    def test_no_consts(self):
        args = build_args("lp_dir/", "/tmp/task.lp", {})
        assert args == ["lp_dir/define.lp", "lp_dir/generate.lp", "lp_dir/test.lp", "lp_dir/optimize.lp", "lp_dir/output.lp", "/tmp/task.lp", "--outf=2"]

    def test_build(self):
        args = build_args("lp_dir/", "/tmp/task.lp", {"a": 12, "foo": "bar"})
        assert args == ["lp_dir/define.lp", "lp_dir/generate.lp", "lp_dir/test.lp", "lp_dir/optimize.lp", "lp_dir/output.lp", "/tmp/task.lp", "--outf=2", "--consts", "a=12", "foo=bar"]
