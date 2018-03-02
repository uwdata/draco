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
