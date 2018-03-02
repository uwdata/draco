import json
import os
import random
import math
import argparse
from copy import deepcopy
import logging

logging.basicConfig()
logging.getLogger().setLevel(logging.WARN)

from draco.generation.generator import Generator

INTERACTIONS_PATH = os.path.join(
    os.path.dirname(__file__), 'interactions.json')
DISTRIBUTIONS_PATH = os.path.join(
    os.path.dirname(__file__), 'distributions.json')
DEFINITIONS_PATH = os.path.join(os.path.dirname(__file__), 'definitions.json')
DUMMY_SCHEMA_PATH = os.path.join(
    os.path.dirname(__file__), 'dummy_schema.json')

NUM_TRIES = 100
MAX_DIMENSIONS = 4

def main(args):
    interactions = load_json(INTERACTIONS_PATH)
    distributions = load_json(DISTRIBUTIONS_PATH)
    definitions = load_json(DEFINITIONS_PATH)
    dummy_schema = load_json(DUMMY_SCHEMA_PATH)

    generator = Generator(distributions, definitions, dummy_schema)

    chosen = str(args.interaction)
    num_groups = int(args.groups)

    for interaction in interactions:
        specified = interaction['name'] == chosen or chosen == 'all'
        if (interaction['include'] and specified):
            groups = []
            for d in range(1, MAX_DIMENSIONS + 1):
                for group_num in range(num_groups):
                    specs = generator.generate_interaction(interaction['props'], d)

                    tries = 0
                    while (len(specs) < 2 and tries < NUM_TRIES):
                        specs = generator.generate_interaction(interaction['props'], d)
                        tries += 1
                    groups.append(specs)

            output_name = '{0}/{1}.json'.format(args.output_dir, interaction['name'])
            with open(output_name, 'w') as out:
                json.dump(groups, out, indent=2)

def load_json(file_path):
    with open(file_path) as data:
        return json.load(data)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('interaction')
    parser.add_argument('groups')
    parser.add_argument('output_dir')
    args = parser.parse_args()
    main(args)
