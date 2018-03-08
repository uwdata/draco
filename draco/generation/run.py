import argparse
import json
import logging
import os
from copy import deepcopy
import itertools

from draco.generation.generator import Generator

logging.basicConfig()
logging.getLogger().setLevel(logging.WARN)


def absolute_path(path):
    return os.path.join(os.path.dirname(__file__), path)

INTERACTIONS_PATH = absolute_path('define/interactions.json')
DISTRIBUTIONS_PATH = absolute_path('define/distributions.json')
DEFINITIONS_PATH = absolute_path('define/definitions.json')
DUMMY_SCHEMA_PATH = absolute_path('define/dummy_schema.json')
OUTPUT_LIST_PATH = absolute_path('../../draco-tools/public/generated_visualizations/interactions.json')
DATA_URL = 'data/cars_mod.json'

NUM_TRIES = 100
MAX_DIMENSIONS = 3

def main(args):
    logger = logging.getLogger(__name__)

    interactions = load_json(INTERACTIONS_PATH)
    distributions = load_json(DISTRIBUTIONS_PATH)
    definitions = load_json(DEFINITIONS_PATH)
    dummy_schema = load_json(DUMMY_SCHEMA_PATH)

    out_dir = args.output_dir
    num_groups = int(args.groups)

    field_names = [x['name'] for x in dummy_schema]

    generator = Generator(distributions, definitions, dummy_schema, DATA_URL)

    written = []

    for d in range(1, MAX_DIMENSIONS + 1):
        field_subsets = generate_field_subsets(field_names, d)

        out = {}
        groups = []
        for subset in field_subsets:
            name = field_list_to_string(subset)
            group = []

            seen = set()
            for _ in range(num_groups):
                specs = generator.generate_visualizations(subset, seen)

                tries = 0
                while (len(specs) == 0 and tries < NUM_TRIES):
                    specs = generator.generate_visualizations(subset, seen)
                    tries += 1

                if (tries == NUM_TRIES):
                    logger.warning('exceeded maximum tries for {0} exceeded'.format(name))
                    continue

                group.extend(specs)

            if (len(group) < 2):
                continue

            groups.append(group)

        out[1] = groups
        output_name = '{0}/{1}.json'.format(out_dir, d)
        with open(output_name, 'w') as outfile:
            written.append(str(d) + '.json')
            json.dump(out, outfile, indent=4)

    with open(OUTPUT_LIST_PATH, 'w') as f:
        json.dump(written, f, indent=4)

def field_list_to_string(fields):
    result = str(fields[0])
    for field in fields[1:]:
        result += 'x{0}'.format(field)

    return result



def generate_field_subsets(field_names, dimensions):
    """
    Returns a list of subsets of field names with number of dimensions.
    """
    subsets = itertools.combinations(field_names, dimensions)

    return [x for x in subsets if len(x) == dimensions]


def load_json(file_path):
    with open(file_path) as data:
        return json.load(data)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output_dir', '-o', default=absolute_path('../../data/to_label'))
    parser.add_argument('--groups', '-g', default=1)
    args = parser.parse_args()
    main(args)
