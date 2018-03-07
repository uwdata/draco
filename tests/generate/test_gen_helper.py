from draco.generation.helper import is_valid
from draco.spec import Task, Query, Data, Field

def test_is_valid():
    data = Data(fields=[Field('foo', 'number')])

    invalid = Query.from_vegalite({
        'mark': 'text',
        'encoding': {
            'x': {'field': 'foo', 'type': 'quantitative'}
        }
    })

    assert is_valid(Task(data, invalid)) == False

    valid = Query.from_vegalite({
        'mark': 'point',
        'encoding': {
            'x': {'field': 'foo', 'type': 'quantitative'}
        }
    })
    assert is_valid(Task(data, valid)) == True

    data = Data(fields=[Field('n1', 'string'), Field('q1', 'number'), Field('q2', 'number')])

    stack_color = Query.from_vegalite({
        'mark': 'bar',
        'encoding': {
            'x': {
                'type': 'nominal',
                'field': 'n1',
            },
            'y': {
                'type': 'quantitative',
                'field': 'q1',
                'stack': 'zero',
                'aggregate': 'sum'
            },
            'color': {
                'type': 'quantitative',
                'field': 'q2'
            }
        }
    })

    assert is_valid(Task(data, stack_color), debug=True) == True
