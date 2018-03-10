from draco.spec import Data, Field, Query, Task
from draco.generation.helper import is_valid

data = Data(fields=[
    Field('n1', 'string'),
    Field('n2', 'string'),
    Field('q1', 'number'),
    Field('q2', 'number'),
    Field('q3', 'number')
])

class TestValidSpecs():
    def test_hist(self):
        query = Query.from_vegalite({
            'mark': 'bar',
            'encoding': {
                'x': {
                    'type': 'quantitative',
                    'field': 'q1',
                    'bin': True
                },
                'y': {
                    'type': 'quantitative',
                    'aggregate': 'count'
                }
            }
        })

        assert is_valid(Task(data, query), True) == True

    def test_bar(self):
        query = Query.from_vegalite({
            'mark': 'bar',
            'encoding': {
                'x': {
                    'type': 'ordinal',
                    'field': 'n1'
                },
                'y': {
                    'type': 'quantitative',
                    'field': 'q1'
                }
            }
        })

        assert is_valid(Task(data, query), True) == True

    def test_one_bar(self):
        query = Query.from_vegalite({
            'mark': 'bar',
            'encoding': {
                'y': {
                    'type': 'quantitative',
                    'field': 'q1'
                }
            }
        })

        assert is_valid(Task(data, query), True) == True

    def test_scatter(self):
        query = Query.from_vegalite({
            'mark': 'point',
            'encoding': {
                'x': {
                    'type': 'quantitative',
                    'field': 'q1',
                },
                'y': {
                    'type': 'quantitative',
                    'field': 'q2'
                },
                'color': {
                    'type': 'nominal',
                    'field': 'n2'
                },
                'size': {
                    'type': 'quantitative',
                    'field': 'q3'
                }
            }
        })

        assert is_valid(Task(data, query), True) == True


    def test_stack(self):
        query = Query.from_vegalite({
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
                    'type': 'nominal',
                    'field': 'n2'
                }
            }
        })

        assert is_valid(Task(data, query), True) == True

    def test_stack_agg(self):
        query = Query.from_vegalite({
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
                'detail': {
                    'type': 'nominal',
                    'field': 'n2'
                },
                'color': {
                    'type': 'quantitative',
                    'field': 'q2',
                    'aggregate': 'mean'
                }
            }
        })

        assert is_valid(Task(data, query), True) == True

    def test_stack_q_q(self):
        query = Query.from_vegalite({
            'mark': 'area',
            'encoding': {
                'x': {
                    'type': 'quantitative',
                    'field': 'q1',
                    'scale': {'zero': False}
                },
                'y': {
                    'type': 'quantitative',
                    'field': 'q2',
                    'stack': 'zero'
                },
                'color': {
                    'type': 'nominal',
                    'field': 'n1'
                }
            }
        })

        assert is_valid(Task(data, query), True) == True

    def test_heatmap(self):
        query = Query.from_vegalite({
            'mark': 'rect',
            'encoding': {
                'x': {
                    'type': 'nominal',
                    'field': 'n1',
                },
                'y': {
                    'type': 'ordinal',
                    'field': 'q1',
                    'bin': True
                }
            }
        })

        assert is_valid(Task(data, query), True) == True


class TestInvalidSpecs():
    def test_row_only(self):
        query = Query.from_vegalite({
            'mark': 'point',
            'encoding': {
                'row': {
                    'type': 'nominal',
                    'field': 'n1'
                }
            }
        })

        assert is_valid(Task(data, query), True) == False

    def test_q_q_bar(self):
        query = Query.from_vegalite({
            'mark': 'bar',
            'encoding': {
                'x': {
                    'type': 'quantitative',
                    'field': 'q1'
                },
                'y': {
                    'type': 'quantitative',
                    'field': 'q2'
                }
            }
        })

        assert is_valid(Task(data, query), True) == False

    def test_only_one_agg(self):
        query = Query.from_vegalite({
            'mark': 'point',
            'encoding': {
                'x': {
                    'type': 'quantitative',
                    'field': 'q1'
                },
                'y': {
                    'type': 'quantitative',
                    'field': 'q2',
                    'aggregate': 'mean'
                }
            }
        })

        assert is_valid(Task(data, query), True) == False

    def test_stack_multiple(self):
        query = Query.from_vegalite({
            'mark': 'bar',
            'encoding': {
                'x': {
                    'type': 'quantitative',
                    'field': 'q1',
                    'stack': 'zero',
                    'aggregate': 'sum'
                },
                'y': {
                    'type': 'quantitative',
                    'field': 'q2',
                    'stack': 'zero',
                    'aggregate': 'sum'
                },
                'color': {
                    'type': 'nominal',
                    'field': 'n2'
                }
            }
        });

        assert is_valid(Task(data, query), True) == False
