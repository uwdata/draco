import json
import os


from model import Model

INTERACTIONS_PATH = os.path.join(os.path.dirname(__file__), 'interactions.json')
DISTRIBUTIONS_PATH = os.path.join(os.path.dirname(__file__), 'distributions.json')

def main():
  interactions = json.load(open(INTERACTIONS_PATH))
  distributions = json.load(open(DISTRIBUTIONS_PATH))

  model = Model(distributions)
  print(model.generate_enc())


if __name__ == '__main__':
  main()