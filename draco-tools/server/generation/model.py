import numpy as np
import random

class Model:
  def __init__(self, distributions):
    self.distributions = distributions
    self.values = {}
    self.probs = {}

    for spec in distributions:
      self.values[spec] = [x['name'] for x in distributions[spec]['values']]
      self.probs[spec] = [x['probability'] for x in distributions[spec]['values']]

    return

  def generate_enc(self, t_channel=None, t_type=None, t_aggregate=None, t_bin=None,
                   t_scale=None, t_stack=None, t_sort=None, t_timeunit = None):
    """
    Returns an encoding, randomizing non-specified fields.
    """
    enc = {}

    if (t_channel): enc['channel'] = t_channel
    else: enc['channel'] = self.sample_value('channel')

    if (t_type): enc['type'] = t_type
    else: enc['type'] = self.sample_value('type')

    if (t_aggregate): enc['aggregate'] = t_aggregate
    elif (self.include('aggregate')): self.sample_value('aggregate')

    if (t_bin): enc['bin'] = { 'maxbins': t_bin }
    elif (self.include('bin')): self.sample_value('bin')

    if (t_scale): enc['scale'] = Model.get_scale(t_scale)
    elif (self.include('scale')): enc['scale'] = Model.get_scale(self.sample_value('scale'))

    if (t_stack): enc['stack'] = t_stack
    elif (self.include('stack')): enc['stack'] = self.sample_value('stack')

    if (t_sort): enc['sort'] = t_sort
    elif (self.include('sort')): enc['sort'] = self.sample_value('sort')

    if (t_timeunit): enc['timeUnit'] = t_timeunit
    elif (self.include('timeUnit')): enc['timeUnit'] = self.sample_value('timeUnit')

    return enc

  def include(self, spec):
    """
    Decides randomly from `self.distributions` whether or not
    the given spec should be included
    """
    prob = self.distributions[spec]['probability']
    return random.random() < prob

  def sample_value(self, spec):
    """
    Returns a random value for the given spec.
    
    Params:
    distributions -- {object} see `distributions.json`
    spec -- {string} e.g. `mark`, `channel`, etc.
    """
    values = self.values[spec]
    probs = self.probs[spec]

    cumulative = np.cumsum(probs)

    choice = random.random()
    index = np.searchsorted(cumulative, choice)

    return values[index]

  @staticmethod
  def get_scale(t_scale):
    """
    Returns a scale object for the given type.

    type -- `zero` or `log`
    """
    if (t_scale == 'zero'):
      return { 'type': 'linear', 'zero': True }
    elif (t_scale == 'log'):
      return { 'type': 'log' }
    else:
      raise ValueError('scale should be zero or log')

