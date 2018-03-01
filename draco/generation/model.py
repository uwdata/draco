import numpy as np
import random
from copy import deepcopy

from prop_objects import PropObjects

class Model:
  SPECIAL_ENUMS = {
    'bin': PropObjects.get_bin,
    'scale': PropObjects.get_scale,
  }

  UNPACK_SPECIAL_ENUM = {
    'bin': PropObjects.unpack_bin,
    'scale': PropObjects.unpack_scale
  }

  UNIQUE_ENCODING_PROPS = set(['channel'])

  def __init__(self, distributions, top_level_props, encoding_props):
    self.distributions = distributions
    self.top_level_props = set(top_level_props)
    self.encoding_props = set(encoding_props)

    self.enums = {}
    self.probs = {}
    self.enum_probs = {}

    for spec in distributions:
      self.enums[spec] = [x['name'] for x in distributions[spec]['values']]
      self.probs[spec] = [x['probability'] for x in distributions[spec]['values']]

    for prop in self.enums:
      self.enum_probs[prop] = {}
      enums = self.enums[prop]
      probs = self.probs[prop]

      for i in range(len(enums)):
        self.enum_probs[prop][enums[i]] = probs[i]

    return

  def ready(self):
    """
    Prepares this to generate a spec
    """
    self.curr_enums = deepcopy(self.enums)
    self.curr_probs = deepcopy(self.probs)

  def generate_spec(self, n_dimensions):
    """
    Returns a spec, randomizing props.

    n_dimensions -- the number of encodings to generate
    """
    self.ready()
    spec = { 'encodings': [] }
    
    for prop in self.top_level_props:
      if (self.include(prop)):
        spec[prop] = self.sample_enum(prop)
    
    for d in range(n_dimensions):
      enc = self.generate_enc()
      spec['encodings'].append(enc)

    return spec

  def generate_enc(self):
    """
    Returns an encoding, randomizing props.
    """
    enc = {}

    for prop in self.encoding_props:
      if (self.include(prop)):
        enc[prop] = self.sample_prop(prop)

    return enc

  def get_enum_probabilities(self, prop):
    return self.enum_probs[prop]

  def get_enums(self, prop):
    return self.enums[prop]

  def get_top_level_props(self):
    return self.top_level_props

  def get_encoding_props(self):
    return self.encoding_props

  def include(self, prop):
    """
    Decides randomly from `self.distributions` whether or not
    the given spec should be included
    """
    prob = self.distributions[prop]['probability']
    return random.random() < prob

  def sample_prop(self, prop):
    enum = self.sample_enum(prop)
    if (prop in Model.SPECIAL_ENUMS):
      return Model.SPECIAL_ENUMS[prop](enum)

    return enum

  def sample_enum(self, prop):
    """
    Returns a random value for the given prop.
    
    Params:
    distributions -- {object} see `distributions.json`
    spec -- {string} e.g. `mark`, `channel`, etc.
    """
    enums = self.curr_enums[prop]
    probs = self.curr_probs[prop]

    cumulative = np.cumsum(probs)

    choice = random.uniform(0, cumulative[-1])
    index = np.searchsorted(cumulative, choice)
    if (index == len(cumulative)):
      # in case choice rests exactly on the upper bound
      index -= 1

    result = enums[index]

    if (prop in Model.UNIQUE_ENCODING_PROPS):
      enums.pop(index)
      probs.pop(index)

    return result

  @staticmethod
  def get_enums_used_for_prop(model, spec, prop):
    used = set()
    if (prop in model.get_top_level_props() and prop in spec):
      used.add(spec[prop])
    elif (prop in model.get_encoding_props()):
      encodings = spec['encodings']
      
      for enc in encodings:
        if (prop in enc):
          if (prop in Model.UNPACK_SPECIAL_ENUM):
            used.add(Model.UNPACK_SPECIAL_ENUM[prop](enc[prop]))
          else:
            used.add(enc[prop])
    
    return used
