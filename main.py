#!/usr/bin/env python3

from spec import *
import json
import argparse
import subprocess

CONFIG = {
    # the clingcon bin file
    "clingcon": os.path.join("bin", "clingcon-mac"),
    # vegalite file 
    "vega_lite_lp": os.path.join("asp", "vega-lite.lp"),
    # the directory storing temporary files 
    # (e.g., lp files compiled from partial spec)
    "tmp_dir": "__tmp__"
}

# create tmp dir if not exists
if not os.path.exists(CONFIG["tmp_dir"]):
    os.makedirs(CONFIG["tmp_dir"])


def main(partial_vl_spec):
    """ Given a partial vegalite spec, recommand a completion of the spec
    """
    tmp_asp_file = os.path.join(CONFIG["tmp_dir"], os.path.basename(partial_vl_spec).split(".")[0] + ".lp")
    
    # load a task from a spec provided by the user
    task = Task.load_from_vl_json(partial_vl_spec)

    with open(tmp_asp_file, "w") as f:
        print(f"[OK] Temp asp specification written into: {tmp_asp_file} .")
        f.write(task.to_asp())

    r = subprocess.run([CONFIG["clingcon"], CONFIG["vega_lite_lp"], tmp_asp_file], 
                       stdout=subprocess.PIPE, stderr=None)
    
    print("[Solver Output]")
    print(r.stdout.decode("utf-8"))
    

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("vegalite_spec", nargs="?", default=os.path.join("examples", "ab.vl.json"), 
                        help="The partial vegalite spec for completion")
    args = parser.parse_args()

    print(f"[OK] Processing partial vis spec: {args.vegalite_spec} ...")

    main(args.vegalite_spec)
    
    print(f"[OK] Complete task.")

