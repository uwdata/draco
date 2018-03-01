import json
import os
import random
from tqdm import tqdm
from copy import deepcopy

from draco.generation.model import Model
from draco.generation.helper import is_valid
from draco.spec import Task, Data, Query, Field

INTERACTIONS_PATH = os.path.join(os.path.dirname(__file__), 'interactions.json')
DISTRIBUTIONS_PATH = os.path.join(os.path.dirname(__file__), 'distributions.json')
DEFINITIONS_PATH = os.path.join(os.path.dirname(__file__), 'definitions.json')
DUMMY_SCHEMA_PATH = os.path.join(os.path.dirname(__file__), 'dummy_schema.json')

NUM_GROUPS = 10

def main():
  interactions = json.load(open(INTERACTIONS_PATH))
  distributions = json.load(open(DISTRIBUTIONS_PATH))
  definitions = json.load(open(DEFINITIONS_PATH))
  dummy_schema = json.load(open(DUMMY_SCHEMA_PATH))

  model = Model(distributions, definitions['topLevelProps'], definitions['encodingProps'])

  dummy_fields = [Field(x['name'], x['type']) for x in dummy_schema]
  dummy_data = Data(dummy_fields)
  
  out = {}

  for i in tqdm(range(len(interactions))):
    interaction = interactions[i]
    if (interaction['include']):
      groups = []
      for j in range(NUM_GROUPS):
        specs = generate_interaction(model, dummy_data, interaction)
        groups.append(specs)
      
      out[interaction['name']] = groups

  with open('out.json', 'w') as outfile:
    json.dump(out, outfile, indent=2)

def generate_interaction(model, dummy_data, interaction):
  props = interaction['props'].copy()
  base_spec = model.generate_spec(2)

  specs = []
  mutate_spec(model, dummy_data, deepcopy(base_spec), props, specs)
  return specs

def mutate_spec(model, dummy_data, base_spec, props, specs):
  if (not props):
    spec = deepcopy(base_spec)
    populate_field_names(spec)
  
    query = Query.from_vegalite(spec)
    if (is_valid(Task(dummy_data, query))):
      specs.append(spec)
  else:
    prop_to_mutate = props.pop(0)

    is_top_level_prop = prop_to_mutate in model.get_top_level_props()
    used_enums = Model.get_enums_used_for_prop(model, base_spec, prop_to_mutate)

    for enum in model.get_enums(prop_to_mutate):
      if (is_top_level_prop):
        base_spec[prop_to_mutate] = enum
        mutate_spec(model, dummy_data, base_spec, props, specs)
      elif (not enum in used_enums):
        encodings = base_spec['encodings']
        index = random.randint(0, len(encodings) - 1)

        before = None
        if (prop_to_mutate in encodings[index]):
          before = encodings[index][prop_to_mutate]

        encodings[index][prop_to_mutate] = enum
        mutate_spec(model, dummy_data, base_spec, props, specs)

        if (not before is None):
          encodings[index][prop_to_mutate] = before
  
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

    

if __name__ == '__main__':
  main()