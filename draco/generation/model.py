import random
import inspect
from copy import deepcopy

import numpy as np

from draco.generation.spec import Spec
from draco.generation.prop_objects import PropObjects


class Model:
    SPECIAL_ENUMS = {
        'bin': PropObjects.get_bin,
        'scale': PropObjects.get_scale,
    }

    UNPACK_SPECIAL_ENUM = {
        'bin': PropObjects.unpack_bin,
        'scale': PropObjects.unpack_scale
    }

    UNIQUE_ENCODING_PROPS = set(['stack'])

    TYPE_PROBABILITIES = {
        'number': {
            'quantitative': 0.85,
            'ordinal': 0.1,
            'nominal': 0.05,
            'temporal': 0
        },
        'string': {
            'nominal': 0.9,
            'ordinal': 0.1,
            'quantitative': 0,
            'temporal': 0
        },
        'datetime': {
            'temporal': 1,
            'quantitative': 0,
            'nominal': 0,
            'ordinal': 0
        }
    }

    def __init__(self, data_fields, distributions, top_level_props, encoding_props):
        self.fields = {x.name:x.ty for x in data_fields}

        print(self.fields)
        self.distributions = distributions
        self.top_level_props = set(top_level_props)
        self.encoding_props = set(encoding_props)

        self.enums = {}
        self.probs = {}
        self.enum_probs = {}

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

    def generate_spec(self, n_dimensions):
        """
        Returns a spec, randomizing props.

        n_dimensions -- the number of encodings to generate
        """
        self.__ready()
        spec = Spec()

        for prop in self.top_level_props:
            if (self.__include(prop)):
                spec[prop] = self.__sample_prop(prop)

        for _ in range(n_dimensions):
            enc = self.__generate_enc()

            channel = self.__sample_prop('channel')
            spec['encoding'][channel] = enc

        return spec

    def populate_types(self, spec):
        for channel in spec['encoding']:
            enc = spec['encoding'][channel]

            field_name = enc['field']
            field_value_type = self.fields[field_name]
            distribution = Model.TYPE_PROBABILITIES[field_value_type]

            types = list(distribution.keys())
            probs = [distribution[x] for x in types]

            field_type, _ = Model.sample(types, probs)
            enc['type'] = field_type
        return

    def improve(self, spec):
        """
        Improves the given spec to fit certain soft constraints
        """

        # gets all functions from class Improve to call on spec
        attr_names = [attr for attr in dir(Improvements)]
        improvements = []
        for name in attr_names:
            attr = getattr(Improvements, name)
            if (inspect.isfunction(attr)):
                improvements.append(attr)

        for imp in improvements:
            imp(spec)

        return

    def get_enums(self, prop):
        return self.enums[prop]

    def __ready(self):
        """
        Prepares this to generate a spec
        """
        self.curr_enums = deepcopy(self.enums)
        self.curr_probs = deepcopy(self.probs)
        self.used_enc_props = set()

    def __generate_enc(self):
        """
        Returns an encoding, randomizing props.
        """
        enc = {}

        for prop in self.encoding_props:
            if (self.__include(prop)):
                self.used_enc_props.add(prop)
                enc[prop] = self.__sample_prop(prop)

        return enc

    def __include(self, prop):
        """
        Decides randomly from `self.distributions` whether or not
        the given spec should be included
        """
        prob = self.distributions[prop]['probability']
        picked = random.random() < prob

        allowed = (prop not in Model.UNIQUE_ENCODING_PROPS or
                   prop not in self.used_enc_props)

        return picked and allowed

    def __sample_prop(self, prop):
        enum = self.__sample_enum(prop)
        if (prop in Model.SPECIAL_ENUMS):
            return Model.SPECIAL_ENUMS[prop](enum)

        return enum

    def __sample_enum(self, prop):
        """
        Returns a random value for the given prop.

        Params:
        distributions -- {object} see `distributions.json`
        spec -- {string} e.g. `mark`, `channel`, etc.
        """
        enums = self.curr_enums[prop]
        probs = self.curr_probs[prop]

        result, index = Model.sample(enums, probs)

        if (prop == 'channel'):
            enums.pop(index)
            probs.pop(index)

        return result

    @staticmethod
    def sample(enums, probs):
        cumulative = np.cumsum(probs)

        choice = random.uniform(0, cumulative[-1])
        index = np.searchsorted(cumulative, choice)
        if (index == len(cumulative)):
            # in case choice rests exactly on the upper bound
            index -= 1

        result = enums[index]

        return result, index

    @staticmethod
    def build_value_from_enum(prop, enum):
        if (prop in Model.SPECIAL_ENUMS):
            return Model.SPECIAL_ENUMS[prop](enum)
        else:
            return enum

    @staticmethod
    def get_enc_by_channel(spec, channel):
        if (channel in spec['encoding']):
            return spec['encoding'][channel]
        return None

class Improvements:
    @staticmethod
    def improve_aggregate(spec):
        """
        Give an aggregate to bar, line, area
        plots that are not qxq unless we are inspecting
        aggregate.
        """
        if (not spec['mark'] in ['bar', 'line', 'area']):
            return

        x_enc = spec.get_enc_by_channel('x')
        y_enc = spec.get_enc_by_channel('y')

        if (x_enc is None or y_enc is None):
            return
        if ((x_enc['type'] != 'quantitative') != (y_enc['type'] != 'quantitative')):
            q_enc = x_enc if x_enc['type'] == 'quantitative' else y_enc
            q_enc['aggregate'] = 'mean'

        return

    @staticmethod
    def improve_bar(spec):
        """
        Adds `scale: { 'zero': True }` to the given spec
        if the mark is a bar.
        """
        if (spec['mark'] == 'rect'):
            spec['scale'] = { 'zero': True }

        return

    @staticmethod
    def improve_stack(spec):
        """
        If we are trying to inspect 'stack' in an interaction,
        we force bar or area marks. In any case,
        We also only want to stack on x and y, and stack should
        be accompanied by aggregate.
        """
        if (spec.contains_prop('stack')):
            mark = 'bar' if random.random() < 0.5 else 'area'
            spec['mark'] = mark


        for channel in spec['encoding']:
            enc = spec['encoding'][channel]
            if ('stack' in enc):
                if (not (channel == 'x' or channel == 'y')):
                    del enc['stack']
                elif ('aggregate' not in enc):
                    aggregate = 'sum' if random.random() < 0.5 else 'count'
                    enc['aggregate'] = aggregate
