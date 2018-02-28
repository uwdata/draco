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
  print(model.generate_spec({}, 2))

if __name__ == '__main__':
  main()