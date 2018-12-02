"""
Reads the weights file and generates assign_weights.lp and weights.json
"""

import json
import os
import re


def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), p)


def main():
    with open(absolute_path("weights.lp")) as weight_constants, open(
        absolute_path("assign_weights.lp"), "w"
    ) as assign, open(absolute_path("../data/weights.json"), "w") as weights_json:

        assign.write("%% GENERATED FILE. DO NOT EDIT.\n\n")

        weights = {}

        for line in weight_constants.readlines():
            match = re.search("#const (.*)_weight = ([\-0-9]*)", line)
            if match:
                name = match.group(1)
                value = int(match.group(2))

                weights[f"{name}_weight"] = value

                assign.write(f"soft_weight({name},{name}_weight).\n")

        json.dump(weights, weights_json, indent=2)


if __name__ == "__main__":
    main()
