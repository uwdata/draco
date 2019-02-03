"""
Reads the weights file and generates assign_weights.lp and weights.json
"""

import json
import os
import re


def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), p)


def main():
    with open(absolute_path("compare_weights.lp")) as weight_constants, open(
        absolute_path("assign_compare_weights.lp"), "w"
    ) as assign:

        assign.write("%% GENERATED FILE. DO NOT EDIT.\n\n")

        weights = {}

        for line in weight_constants.readlines():
            match = re.search("#const (.*)_weight = ([\-0-9]*)", line)
            if match:
                name = match.group(1)
                value = int(match.group(2))

                weights[f"{name}_weight"] = value

                assign.write(f"compare_weight({name},{name}_weight).\n")

if __name__ == "__main__":
    main()
``