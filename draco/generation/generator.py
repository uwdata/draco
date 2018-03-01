import json
import os

from model import Model

INTERACTIONS_PATH = os.path.join(os.path.dirname(__file__), 'interactions.json')
DISTRIBUTIONS_PATH = os.path.join(os.path.dirname(__file__), 'distributions.json')
DEFINITIONS_PATH = os.path.join(os.path.dirname(__file__), 'definitions.json')

def main():
  interactions = json.load(open(INTERACTIONS_PATH))
  distributions = json.load(open(DISTRIBUTIONS_PATH))
  definitions = json.load(open(DEFINITIONS_PATH))

  model = Model(distributions, definitions['topLevelProps'], definitions['encodingProps'])
  
  for interaction in interactions:
    if (interaction['include']):
      generate_interaction(model, interaction)

def generate_interaction(model, interaction):
  fields = interaction['fields'].copy()
  specs = []
  generate_specs(model, fields, { 'encodings': [] }, specs)
  return specs

def generate_specs(model, fields, partial, specs):
  if (not fields):
    spec = model.generate_spec(partial, 2)
    return

  field = fields.pop(0)
  enums = model.get_enums(field)

  for enum in enums:
    if (field in model.get_top_level_props()):
      partial[field] = enum
      generate_specs(model, fields, partial, specs)
      del partial[field]
    else:
      partial['encodings'].append({ field: enum })
      generate_specs(model, fields, partial, specs)
      partial['encodings'].pop()
    

  return



if __name__ == '__main__':
  main()