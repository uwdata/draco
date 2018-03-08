import random
from copy import deepcopy
import itertools

from draco.generation.helper import is_valid
from draco.generation.model import Model
from draco.spec import Data, Field, Query, Task


class Generator:
    def __init__(self, distributions, definitions, data_schema, data_url):
        top_level_props = definitions['topLevelProps']
        encoding_props = definitions['encodingProps']
        data_fields = [Field(x['name'], x['type']) for x in data_schema]
        vl_fields = {x['name']:x['vltype'] for x in data_schema}

        self.model = Model(vl_fields, distributions, top_level_props, encoding_props)
        self.data = Data(data_fields)
        self.data_url = data_url


    def generate_visualizations(self, field_names, seen=set()):
        """
        A base_spec contains ONLY field names.
        """
        specs = []

        dimensions = len(field_names)
        base_spec = self.model.generate_spec(dimensions)

        permutations = list(itertools.permutations(field_names))

        random_perm = random.choice(permutations)

        spec = deepcopy(base_spec)

        for index, channel in enumerate(spec['encoding']):
            enc = spec['encoding'][channel]
            enc['field'] = random_perm[index]

        self.model.populate_types(spec)
        self.model.improve(spec)

        spec_no_field_names = Generator.strip_field_names(spec)
        if not (spec_no_field_names in seen):
            seen.add(spec_no_field_names)

            query = Query.from_vegalite(spec)

            if (is_valid(Task(self.data, query))):
                spec['data'] = { 'url': self.data_url }
                specs.append(spec)

        return specs

    @staticmethod
    def strip_field_names(spec):
        stripped = deepcopy(spec)

        for channel in stripped['encoding']:
            enc = stripped['encoding'][channel]
            del enc['field']

        return stripped

