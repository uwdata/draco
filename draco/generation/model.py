import random
import inspect
from copy import deepcopy
from typing import Any, Dict, List, Tuple

import numpy as np
from sortedcontainers import SortedDict

from draco.generation.spec import Spec
from draco.generation.prop_objects import PropObjects
from draco.spec import Field

class Model:
    """
    A model handles the generation and improvement
    of random specs.
    """

    # enums that require non-primitive values
    SPECIAL_ENUMS = {
        'bin': PropObjects.get_bin,
        'scale': PropObjects.get_scale,
    }

    # only 1 of these can appear in all encodings
    UNIQUE_ENCODING_PROPS = set(['stack'])

    def __init__(self, fields: List[Field], distributions: Dict, type_distribution: Dict,
                       top_level_props: List[str], encoding_props: List[str]) -> None:
        """
        distributions -- see distributions.json
        top_level_props -- a list of top level properties
        encoding_props -- a list of encoding level properties
        """
        self.fields = fields
        self.distributions = distributions
        self.type_distribution = type_distribution
        self.top_level_props = set(top_level_props)
        self.encoding_props = set(encoding_props)

        self.enums: Dict[str, List[str]] = {}
        self.probs: Dict = {}
        self.enum_probs: Dict = {}

        for spec in distributions:
            self.enums[spec] = [x['name']
                                for x in distributions[spec]['values']]
            self.probs[spec] = [x['probability']
                                for x in distributions[spec]['values']]

        for prop in self.enums:
            self.enum_probs[prop] = {}
            enums = self.enums[prop]
            probs = self.probs[prop]

            for i in range(len(enums)):
                self.enum_probs[prop][enums[i]] = probs[i]

        return

    def generate_spec(self, n_dimensions: int):
        """
        Returns a spec, randomizing props.

        n_dimensions -- the number of encodings to generate
        """
        self.__ready()
        spec = Spec()
        spec['encoding'] = SortedDict()

        for prop in self.top_level_props:
            if (self.__include(prop)):
                spec[prop] = self.__sample_prop(prop)

        for _ in range(n_dimensions):
            enc = self.__generate_enc()

            channel = self.__sample_prop('channel')
            spec['encoding'][channel] = enc

        return spec

    def mutate_prop(self, spec: Spec, prop: str, enum: str):
        """
        Mutates the prop in the given spec to the given enum.
        """
        if not (prop in self.top_level_props or prop == 'channel' or
                prop in self.encoding_props):
            raise ValueError('invalid prop {0}'.format(prop))

        if (prop in self.top_level_props):
            spec[prop] = Model.build_value_from_enum(prop, enum)

        elif (prop == 'channel' and not enum in spec['encoding']):
            used_channels = list(spec['encoding'].keys())

            # the least likely channel has the highest prob of being replaced
            probs = [(1 - self.enum_probs['channel'][x]) for x in used_channels]
            to_replace, _ = Model.sample(used_channels, probs)


            enc = spec['encoding'][to_replace]
            del spec['encoding'][to_replace]
            spec['encoding'][enum] = enc

        elif (prop in self.encoding_props):
            used_channels = list(spec['encoding'].keys())

            # the most likely channel has the highest prob of being modified
            probs = [self.enum_probs['channel'][x] for x in used_channels]
            to_modify, _ = Model.sample(used_channels, probs)

            enc = spec['encoding'][to_modify]
            enc[prop] = Model.build_value_from_enum(prop, enum)

        return

    def pre_improve(self, spec: Spec, props: List[str]):
        """
        Improves the given spec to fit a small set of hard constraints
        and improve comparisons
        This will run all methods found in class PreImprovements.
        """
        self.__improve(spec, props, PreImprovements)
        return

    def post_improve(self, spec: Spec, props: List[str]):
        """
        Improves the given spec to fit a small set of hard constraints
        and improve comparisons
        This will run all methods found in class PostImprovements.
        """
        self.__improve(spec, props, PostImprovements)
        return

    def get_enums(self, prop: str) -> List[str]:
        """
        Returns the enums for the given prop
        """
        return self.enums[prop]

    def __improve(self, spec: Spec, props: List[str], improvement_class):
        """
        Runs all improvements in the given improvement_class over the given spec.
        """
        attr_names = [attr for attr in dir(improvement_class)]
        improvements = []
        for name in attr_names:
            attr = getattr(improvement_class, name)
            if (inspect.isfunction(attr)):
                improvements.append(attr)

        for imp in improvements:
            imp(spec, props)

    def __ready(self):
        """
        Prepares this to generate a spec
        """
        self.curr_enums = deepcopy(self.enums)
        self.curr_probs = deepcopy(self.probs)
        self.used_enc_props = set()
        self.available_fields = deepcopy(self.fields)

    def __generate_enc(self):
        """
        Returns an encoding, randomizing props.
        """
        enc = SortedDict()

        # set the field / type
        field_name, vl_type = self.__sample_field()

        # special case for count
        if (field_name == 'count'):
            enc['aggregate'] = 'count'
            enc['type'] = 'quantitative'
            return enc

        enc['field'] = field_name
        enc['type'] = vl_type

        # everything else
        for prop in self.encoding_props:
            if (self.__include(prop)):
                self.used_enc_props.add(prop)
                enc[prop] = self.__sample_prop(prop)

        return enc

    def __sample_field(self) -> Tuple[str, str]:
        field_index = random.randrange(len(self.available_fields))
        field = self.available_fields.pop(field_index)

        vl_type = None
        if (field.ty == 'string' or field.ty == 'boolean'):
            # strings and booleans are always nominal
            vl_type = 'nominal'
        elif (field.ty == 'datetime'):
            vl_type = 'temporal'
        elif (field.ty == 'number'):
            # we need to decide between nominal, ordinal, quantitative,
            # based off the cardinality
            vl_type = Model.sample_vl_type(field.cardinality)
        else:
            raise Exception('No type for %s', field.ty)

        return field.name, vl_type

    def __include(self, prop: str) -> bool:
        """
        Decides randomly from `self.distributions` whether or not
        the given spec should be included
        """
        prob = self.distributions[prop]['probability']
        picked = random.random() < prob

        allowed = (prop not in Model.UNIQUE_ENCODING_PROPS or
                   prop not in self.used_enc_props)

        return picked and allowed

    def __sample_prop(self, prop: str) -> Any:
        """
        Returns a random value (enum or object) for the given prop.
        """
        enum = self.__sample_enum_value(prop)
        if (prop in Model.SPECIAL_ENUMS):
            return Model.SPECIAL_ENUMS[prop](enum)

        return enum

    def __sample_enum_value(self, prop: str) -> str:
        """
        Returns a random enum for the given prop.

        Params:
        distributions -- {object} see `distributions.json`
        spec -- {string} e.g. `mark`, `channel`, etc.
        """
        enums = self.curr_enums[prop]
        probs = self.curr_probs[prop]

        try:
            result, index = Model.sample(enums, probs)
            if (prop == 'channel'):
                enums.pop(index)
                probs.pop(index)

            return result
        except ValueError:
            raise ValueError('{0} empty'.format(prop))

    @staticmethod
    def sample(enums: List[str], probs: List[float]) -> Tuple[str, int]:
        """
        Returns a probabilistic choice and index from the given list
        of enums, where probs[i] = probability for enums[i]. Expects sum(probs) = 1
        """
        if (not probs):
            raise ValueError()

        cumulative = np.cumsum(probs)

        choice = random.uniform(0, cumulative[-1])
        index = np.searchsorted(cumulative, choice)
        if (index == len(cumulative)):
            # in case choice rests exactly on the upper bound
            index -= 1

        result = enums[index]

        return result, index

    @staticmethod
    def sample_vl_type(cardinality: int) -> str:
        """
        Samples a vega-lite type for a numerical field based
        off its cardinality.
        """
        # tanh with coef of 0.12, which gives us prob of picking
        # quantitative at 98.5% when cardinality is 20.
        coef = 0.12

        q_prob = np.tanh(coef * cardinality)

        if (random.random() < q_prob):
            return 'quantitative'
        else:
            return random.choice(['nominal', 'quantitative'])

    @staticmethod
    def build_value_from_enum(prop: str, enum: str) -> Any:
        """
        Builds a value for the given prop using given enum
        value. For example scale requires an object as its value,
        even as the enums for scale are strings.
        """
        if (prop in Model.SPECIAL_ENUMS):
            return Model.SPECIAL_ENUMS[prop](enum)
        else:
            return enum

class PreImprovements:
    """
    Optimizations to base specs to avoid failing hard constraints
    and increase quality of comparison
    """
    @staticmethod
    def improve_stack(spec, props):
        """
        If we are trying to inspect 'stack' in an interaction,
        we force bar or area marks. In any case,
        We also only want to stack on x and y, and stack should
        be accompanied by aggregate.
        """
        if ('stack' in props):
            mark = 'bar' if random.random() < 0.7 else 'area'
            spec['mark'] = mark

        # TODO: add a 'memory' to the spec for the aggregate type
        # such that mutations of the same base spec can be improved
        # in the same manner in post.

class PostImprovements:
    """
    Optimizations to completed specs to avoid failing hard constraints and
    to increase quality of comparison.
    """
    @staticmethod
    def improve_aggregate(spec: Spec, props: List[str]):
        """
        Give an aggregate to bar, line, area
        plots that are not qxq unless we are inspecting
        aggregate.
        """
        if (spec['mark'] in ['bar', 'line', 'area']):
            if ('aggregate' not in props):
                x_enc = spec.get_enc_by_channel('x')
                y_enc = spec.get_enc_by_channel('y')

                if (x_enc is None or y_enc is None or len(spec['encoding']) > 2):
                    return
                if ((x_enc['type'] != 'quantitative') != (y_enc['type'] != 'quantitative')):
                    q_enc = x_enc if x_enc['type'] == 'quantitative' else y_enc
                    q_enc['aggregate'] = 'mean'

        return

    @staticmethod
    def improve_bar(spec: Spec, props: List[str]):
        """
        Adds `scale: { 'zero': True }` to the given spec
        if the mark is a bar.
        """
        if (spec['mark'] == 'bar'):
            x_enc = spec.get_enc_by_channel('x')
            y_enc = spec.get_enc_by_channel('x')

            if (x_enc is None or y_enc is None):
                return

            zero_enc = x_enc if x_enc['type'] == 'quantitative' else y_enc
            zero_enc['scale'] = {'zero': True }

        return

    @staticmethod
    def improve_stack(spec: Spec, props: List[str]):
        """
        Ensures stack encodings are aggregated as well.
        """
        for channel in spec['encoding']:
            enc = spec['encoding'][channel]
            if ('stack' in enc):
                if (not (channel == 'x' or channel == 'y')):
                    del enc['stack']
                elif ('aggregate' not in enc):
                    aggregate = 'sum'
                    enc['aggregate'] = aggregate
