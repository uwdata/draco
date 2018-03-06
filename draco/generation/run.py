import argparse
import json
import logging
import os
from copy import deepcopy

from draco.generation.generator import Generator

logging.basicConfig()
logging.getLogger().setLevel(logging.WARN)


def absolute_path(path):
    return os.path.join(os.path.dirname(__file__), path)

INTERACTIONS_PATH = absolute_path('interactions.json')
DISTRIBUTIONS_PATH = absolute_path('distributions.json')
DEFINITIONS_PATH = absolute_path('definitions.json')
DUMMY_SCHEMA_PATH = absolute_path('dummy_schema.json')

NUM_TRIES = 100
MAX_DIMENSIONS = 4

def main(args):
    interactions = load_json(INTERACTIONS_PATH)
    distributions = load_json(DISTRIBUTIONS_PATH)
    definitions = load_json(DEFINITIONS_PATH)
    dummy_schema = load_json(DUMMY_SCHEMA_PATH)

    out_dir = args.output_dir

    generator = Generator(distributions, definitions, dummy_schema)

    chosen = str(args.interaction)
    num_groups = int(args.groups)

    for interaction in interactions:
        specified = interaction['name'] == chosen or chosen == 'all'
        if (interaction['include'] and specified):
            out = {}
            for d in range(1, MAX_DIMENSIONS + 1):
                groups = []
                for _ in range(num_groups):
                    specs = generator.generate_interaction(interaction['props'], d)

                    tries = 0
                    while (len(specs) < 2 and tries < NUM_TRIES):
                        specs = generator.generate_interaction(interaction['props'], d)
                        tries += 1
                    groups.append(specs)

                out[d] = groups

            output_name = '{0}/{1}.json'.format(out_dir, interaction['name'])
            with open(output_name, 'w') as outfile:
                json.dump(out, outfile, indent=4)

def load_json(file_path):
    with open(file_path) as data:
        return json.load(data)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--interaction', '-i', default='all')
    parser.add_argument('--groups', '-g', default=2)
    parser.add_argument('--output_dir', '-o', default=absolute_path('../../data/to_label'))

    args = parser.parse_args()
    main(args)
