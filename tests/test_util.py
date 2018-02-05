from draco.spec import Data
from draco.util import current_weights, count_violations

def test_current_weights():
    assert 'encoding_weight' in current_weights()

def test_count_violations():
    data = Data.from_csv('examples/data/cars.csv')
    violations = count_violations(data, {
        'mark': 'bar',
        'data': {
            'url': 'data/cars.csv'
        },
        'encoding': {
            'x': {
                'field': 'origin',
                'type': 'ordinal'
            },
            'y': {
                'field': 'horsepower',
                'type': 'quantitative',
                'aggregate': 'mean'
            }
        }
    })

    assert 'encoding' in violations
    assert violations['encoding'] == 2
