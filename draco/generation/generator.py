import json
import os
import random
import math
from tqdm import tqdm
from copy import deepcopy

from draco.generation.model import Model
from draco.generation.helper import is_valid
from draco.spec import Task, Data, Query, Field

INTERACTIONS_PATH = os.path.join(os.path.dirname(__file__), 'interactions.json')
DISTRIBUTIONS_PATH = os.path.join(os.path.dirname(__file__), 'distributions.json')
DEFINITIONS_PATH = os.path.join(os.path.dirname(__file__), 'definitions.json')
DUMMY_SCHEMA_PATH = os.path.join(os.path.dirname(__file__), 'dummy_schema.json')

NUM_GROUPS = 20
NUM_TRIES = 100

def main():
  interactions = load_json(INTERACTIONS_PATH)
  distributions = load_json(DISTRIBUTIONS_PATH)
  definitions = load_json(DEFINITIONS_PATH)
  dummy_schema = load_json(DUMMY_SCHEMA_PATH)

  model = Model(distributions, definitions['topLevelProps'], definitions['encodingProps'])

  dummy_fields = [Field(x['name'], x['type']) for x in dummy_schema]
  dummy_data = Data(dummy_fields)

  interaction_groups = []

  count = 0
  pairs = 0
  for i in tqdm(range(len(interactions))):
    interaction = interactions[i]
    if (interaction['include']):
      print(interaction['name'])
      groups = []
      
      for j in tqdm(range(NUM_GROUPS)):

        for d in tqdm(range(1, 4)):
          specs = generate_interaction(model, dummy_data, interaction, d)

          for tries in tqdm(range(NUM_TRIES)):
            specs = generate_interaction(model, dummy_data, interaction, d)
            if (len(specs) >= 2):
              break

          groups.append(specs)
          count += len(specs)
          pairs += math.factorial(len(specs)) // 2
      
      out = { 'interaction': interaction['name'], 'groups': groups }
      with open('out/{0}.json'.format(interaction['name']), 'w') as outfile:
        json.dump(out, outfile, indent=2)

  print('{0} specs with {1} pairs for {2} interactions'.format(count, pairs, len(interactions)))

def generate_interaction(model, dummy_data, interaction, dimensions):
  props = interaction['props'].copy()
  base_spec = model.generate_spec(dimensions)

  specs = []
  mutate_spec(model, dummy_data, deepcopy(base_spec), props, specs)
  return specs

def mutate_spec(model, dummy_data, base_spec, props, specs):
  if (not props):
    spec = deepcopy(base_spec)
    populate_field_names(spec)
  
    to_vegalite(spec)
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

        encodings[index][prop_to_mutate] = Model.build_value_from_enum(prop_to_mutate, enum)
        mutate_spec(model, dummy_data, base_spec, props, specs)

        if (not before is None):
          encodings[index][prop_to_mutate] = before
  
def to_vegalite(spec):
  old_encodings = spec['encodings']
  del spec['encodings']
  spec['encoding'] = {}
  for enc in old_encodings:
    channel = enc['channel']
    del enc['channel']
    spec['encoding'][channel] = enc

  return

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

def load_json(file_path):
  with open(file_path) as data:
    return json.load(data)

if __name__ == '__main__':
  main()