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

INTERACTIONS_PATH = absolute_path('define/interactions.json')
DISTRIBUTIONS_PATH = absolute_path('define/distributions.json')
DEFINITIONS_PATH = absolute_path('define/definitions.json')
DUMMY_SCHEMA_PATH = absolute_path('define/dummy_schema.json')
TYPE_DISTRIBUTIONS = absolute_path('define/type_distribution.json')
DATA_URL = 'data/cars_mod.json'

NUM_TRIES = 100
MAX_DIMENSIONS = 4

def main(args):
    logger = logging.getLogger(__name__)

    interactions = load_json(INTERACTIONS_PATH)
    distributions = load_json(DISTRIBUTIONS_PATH)
    definitions = load_json(DEFINITIONS_PATH)
    dummy_schema = load_json(DUMMY_SCHEMA_PATH)
    type_distribution = load_json(TYPE_DISTRIBUTIONS)

    out_dir = args.output_dir

    generator = Generator(distributions, type_distribution, definitions, dummy_schema, DATA_URL)

    chosen = str(args.interaction)
    num_groups = int(args.groups)

    for interaction in interactions:
        specified = interaction['name'] == chosen or chosen == 'all'
        cross = 'nonCross' not in interaction  # TODO: change to cross

        base_num_groups = interaction['groups'] if num_groups == -1 else num_groups
        if (interaction['include'] and specified):
            out = {}
            for d in range(1, MAX_DIMENSIONS + 1):
                # to not generate too many 1D visualizations
                n = base_num_groups // 4 if d == 1 else base_num_groups

                seen_base_specs = set()
                groups = []
                for _ in range(n):
                    specs = generator.generate_interaction(interaction['props'], d, seen_base_specs, cross)

                    tries = 0
                    while (len(specs) < 2 and tries < NUM_TRIES):
                        specs = generator.generate_interaction(interaction['props'], d, seen_base_specs, cross)
                        tries += 1

                    if (tries == NUM_TRIES):
                        logger.warning('exceeded maximum tries for {0} with d={1}'
                                       .format(interaction['name'], d))
                        continue

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
    parser.add_argument('--groups', '-g', default=-1)
    parser.add_argument('--output_dir', '-o', default=absolute_path('../../data/to_label'))

    args = parser.parse_args()
    main(args)
