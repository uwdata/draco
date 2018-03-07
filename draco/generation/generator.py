import random
from copy import deepcopy

from draco.generation.helper import is_valid
from draco.generation.model import Model
from draco.spec import Data, Field, Query, Task


class Generator:
    def __init__(self, distributions, definitions, data_schema, data_url):
        top_level_props = definitions['topLevelProps']
        encoding_props = definitions['encodingProps']
        data_fields = [Field(x['name'], x['type']) for x in data_schema]

        self.model = Model(distributions, top_level_props, encoding_props)
        self.data = Data(data_fields)
        self.data_url = data_url

    def generate_interaction(self, props, dimensions):
        base_spec = self.model.generate_spec(dimensions)

        specs = []
        self.__mutate_spec(base_spec, props.copy(), specs, set())
        return specs


    def __mutate_spec(self, base_spec, props, specs, seen):
        if (not props):
            self.model.improve(base_spec)

            if not (base_spec in seen):
                seen.add(base_spec)

                self.__populate_field_names(base_spec)
                query = Query.from_vegalite(base_spec)

                if (is_valid(Task(self.data, query))):
                    base_spec['data'] = { 'url': self.data_url }
                    specs.append(base_spec)
        else:
            prop_to_mutate = props.pop(0)
            for enum in self.model.get_enums(prop_to_mutate):
                spec = deepcopy(base_spec)
                self.model.mutate_prop(spec, prop_to_mutate, enum)

                self.__mutate_spec(spec, props, specs, seen)

        return

    def __populate_field_names(self, spec):
        counts = {
            'n': 1, 'o': 1, 'q': 1, 't': 1
        }

        encodings = spec['encoding']
        for channel in encodings:
            enc = encodings[channel]

            field_type = enc['type'][:1]
            field_name = field_type + str(counts[field_type])
            counts[field_type] += 1

            enc['field'] = field_name
