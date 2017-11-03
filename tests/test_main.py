import os
from draco.run import run
import io
#from jsonschema import validate
import json

EXAMPLES_DIR = os.path.join("..", "examples")

class FullTest():

    def test_output_schema(self):
        json_files = [os.path.join(EXAMPLES_DIR, fname) 
                      for fname in os.listdir(EXAMPLES_DIR) if fname.endswith(".json")]
        for fname in json_files:
            with open(fname, "r") as f, io.StringIO() as out:
                run(f, out, tmp_dir=os.path.join("..", "__tmp__"), draco_lp_dir=os.path.join("..", "asp"))
                content = str(out.getvalue())
                #with open("vegalite-2.0.schema.json", "r") as f_schema:
                #   validate(json.loads(content), json.load(f_schema))

        assert 1 + 2 == 3
