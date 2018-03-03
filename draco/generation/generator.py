from copy import deepcopy
import random
import math

from draco.generation.model import Model
from draco.generation.helper import is_valid
from draco.spec import Task, Data, Query, Field

class Generator:
    def __init__(self, distributions, definitions, data_schema):
        top_level_props = definitions['topLevelProps']
        encoding_props = definitions['encodingProps']
        data_fields = [Field(x['name'], x['type']) for x in data_schema]

        self.model = Model(distributions, top_level_props, encoding_props)
        self.data = Data(data_fields)


    def generate_interaction(self, props, dimensions):
        base_spec = self.model.generate_spec(dimensions)

        specs = []
        Generator.mutate_spec(self.model, self.data, deepcopy(base_spec), props.copy(), specs)
        return specs


    @staticmethod
    def mutate_spec(model, dummy_data, base_spec, props, specs):
        if (not props):
            spec = deepcopy(base_spec)
            Generator.populate_field_names(spec)

            Generator.to_vegalite(spec)
            query = Query.from_vegalite(spec)
            if (is_valid(Task(dummy_data, query))):
                specs.append(spec)
        else:
            prop_to_mutate = props.pop(0)

            is_top_level_prop = prop_to_mutate in model.get_top_level_props()
            used_enums = Model.get_enums_used_for_prop(
                model, base_spec, prop_to_mutate)

            for enum in model.get_enums(prop_to_mutate):
                if (is_top_level_prop):
                    base_spec[prop_to_mutate] = enum
                    Generator.mutate_spec(model, dummy_data, base_spec, props, specs)
                elif (not enum in used_enums):
                    encodings = base_spec['encodings']
                    index = random.randint(0, len(encodings) - 1)

                    before = None
                    if (prop_to_mutate in encodings[index]):
                        before = encodings[index][prop_to_mutate]

                    encodings[index][prop_to_mutate] = Model.build_value_from_enum(
                        prop_to_mutate, enum)
                    Generator.mutate_spec(model, dummy_data, base_spec, props, specs)

                    if (not before is None):
                        encodings[index][prop_to_mutate] = before
                else:
                    Generator.mutate_spec(model, dummy_data, base_spec, props, specs)

    @staticmethod
    def to_vegalite(spec):
        old_encodings = spec['encodings']
        del spec['encodings']
        spec['encoding'] = {}
        for enc in old_encodings:
            channel = enc['channel']
            del enc['channel']
            spec['encoding'][channel] = enc
        return


    @staticmethod
    def populate_field_names(spec):
        counts = {
            'n': 1, 'o': 1, 'q': 1, 't': 1
        }

        encodings = spec['encodings']
        for enc in encodings:
            field_type = enc['type'][:1]
            field_name = field_type + str(counts[field_type])
            counts[field_type] += 1

            enc['field'] = field_name
