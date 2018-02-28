import numpy as np
import random

from field_objects import FieldObjects

class Model:
  SPECIAL_ENUMS = {
    'bin': FieldObjects.get_bin,
    'scale': FieldObjects.get_scale,
  }

  def __init__(self, distributions, top_level_props, encoding_props):
    self.distributions = distributions
    self.top_level_props = top_level_props
    self.encoding_props = encoding_props

    self.enums = {}
    self.probs = {}

    for spec in distributions:
      self.enums[spec] = [x['name'] for x in distributions[spec]['values']]
      self.probs[spec] = [x['probability'] for x in distributions[spec]['values']]

    return

  def generate_spec(self, partial, n_dimensions):
    """
    Returns a spec, randomizing non-specified fields.

    partial -- a partial (flat) spec
    n_dimensions -- the number of encodings to generate
    """
    spec = {}
    for field in self.top_level_props:
      if field in partial:
        spec[field] = partial[field]
      elif (self.include(field)):
        spec[field] = self.sample_field(field)

    encodings = []
    for i in range(n_dimensions):
      if (i < len(partial['encodings'])):
        enc = self.generate_enc(partial['encodings'][i])
      else:
        enc = self.generate_enc({})
      encodings.append(enc)

    spec['encodings'] = encodings

    return spec

  def generate_enc(self, partial_enc):
    """
    Returns an encoding, randomizing non-specified fields.
    """
    enc = {}

    for field in self.encoding_props:
      if field in partial:
        enc[field] = partial[field]
      elif (self.include(field)):
        enc[field] = self.sample_field(field)


    return enc

  def get_enums(self, field):
    return self.enums[field]

  def get_top_level_props(self):
    return self.top_level_props

  def get_encoding_props(self):
    return self.encoding_props

  def include(self, field):
    """
    Decides randomly from `self.distributions` whether or not
    the given spec should be included
    """
    prob = self.distributions[field]['probability']
    return random.random() < prob

  def sample_field(self, field):
    enum = self.sample_enum(field)
    if (field in Model.SPECIAL_ENUMS):
      return Model.SPECIAL_ENUMS[field](enum)

    return enum

  def sample_enum(self, field):
    """
    Returns a random value for the given field.
    
    Params:
    distributions -- {object} see `distributions.json`
    spec -- {string} e.g. `mark`, `channel`, etc.
    """
    enums = self.enums[field]
    probs = self.probs[field]

    cumulative = np.cumsum(probs)

    choice = random.random()
    index = np.searchsorted(cumulative, choice)

    return enums[index]
