from draco.spec import Data, Field
from draco.util import count_violations

def learn_weights():
    data = Data([
            Field('q1', 'number', 100, 1),
            Field('q2', 'number', 100, 1),
            Field('n1', 'string', 5, 1)
        ], url='weather.csv')

    # data, inferior spec, superior spec
    training_specs = [(data,
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q2', 'type': 'quantitative'}}},
        {'mark': 'point', 'encoding': {'x': {'field': 'q1',' type': 'quantitative'}, 'y': {'field': 'q1', 'type': 'quantitative'}}}
    )]

    # convert the specs to feature vectors
    training_data = []
    for data, spec1, spec2 in training_specs:
        training_data.append((
            count_violations(spec1, data),
            count_violations(spec2, data)))

    # learn the weights from the feature vectors
    for example in training_data:
        print(example)

if __name__ == '__main__':
    learn_weights()
