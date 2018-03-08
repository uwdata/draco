import random
from copy import deepcopy
from typing import Any, Dict, List, Set

from draco.generation.helper import is_valid
from draco.generation.model import Model
from draco.generation.spec import Spec
from draco.spec import Data, Field, Query, Task


class Generator:
    """
    A Generator can be used to generate specs that represent
    mutations over a list of properties.
    """
    def __init__(self, distributions: Dict, definitions: Dict, data_schema: Dict, data_url: str):
        top_level_props = definitions['topLevelProps']
        encoding_props = definitions['encodingProps']
        data_fields = [Field(x['name'], x['type']) for x in data_schema]

        self.model = Model(distributions, top_level_props, encoding_props)
        self.data = Data(data_fields)
        self.data_url = data_url

    def generate_interaction(self, props: List[str], dimensions: int,
                                   seen_base_specs: Set[Spec]) -> List[Spec]:
        """
        Generates a list of specs by enumerating over the given properties' enums.
        """
        base_spec = self.model.generate_spec(dimensions)
        self.model.pre_improve(base_spec, props)

        while (base_spec in seen_base_specs):
            base_spec = self.model.generate_spec(dimensions)
            self.model.pre_improve(base_spec, props)

        seen_base_specs.add(base_spec)

        specs = []
        self.__mutate_spec(base_spec, props, 0, set(), specs)
        return specs


    def __mutate_spec(self, base_spec: Spec, props: List[str], prop_index: int,
                            seen: Set[Spec], specs: List[Spec]):
        # base case
        if (prop_index == len(props)):
            self.model.post_improve(base_spec, props)

            # within a group, don't repeat the same specs
            if not (base_spec in seen):
                seen.add(base_spec)

                self.__populate_field_names(base_spec)
                query = Query.from_vegalite(base_spec)

                if (is_valid(Task(self.data, query))):
                    base_spec['data'] = { 'url': self.data_url }
                    specs.append(base_spec)
         # recursive case
        else:
            prop_to_mutate = props[prop_index]
            for enum in self.model.get_enums(prop_to_mutate):
                spec = deepcopy(base_spec)
                self.model.mutate_prop(spec, prop_to_mutate, enum)

                # recursive call
                self.__mutate_spec(spec, props, prop_index + 1, seen, specs)

        return

    def __populate_field_names(self, spec: Spec):
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
