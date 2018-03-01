from draco.spec import Data, Task, Query
from draco.learn.helper import current_weights, count_violations

def test_current_weights():
    assert 'encoding_weight' in current_weights()

def test_count_violations():
    data = Data.from_csv('examples/data/cars.csv')
    query_json = {
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
    }
    violations = count_violations(Task(data, Query.from_vegalite(query_json)))

    assert 'encoding' in violations.keys()
    assert violations.get('encoding') == 2
