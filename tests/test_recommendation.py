import unittest

from draco.run import run
from draco.spec import Data, Field, Query, Task


def get_rec(data, query):
    query = Query.from_obj(query)
    input_task = Task(data, query)
    return run(input_task)

def run_spec(data, spec):
    query = Query.from_vegalite(spec)
    input_task = Task(data, query)
    return run(input_task)

spec_schema = Data([
        Field('q1', 'number', 100, 1),
        Field('q2', 'number', 100, 1),
        Field('o1', 'number', 6, 1),
        Field('n1', 'string', 5, 1)
    ], 100, url='data.csv')

class TestSpecs():
    def test_scatter(self):
        recommendation = get_rec(spec_schema, {
            'encoding': [{'channel': 'x', 'field': 'q1'}, {'field': 'q2'}]
        }).to_vegalite()

        assert recommendation == {
            '$schema': 'https://vega.github.io/schema/vega-lite/v2.json',
            'data': {'url': 'data.csv'},
            'mark': 'point',
            'encoding': {
                'x': {'field': 'q1', 'type': 'quantitative', 'scale': {'zero': True}},
                'y': {'field': 'q2', 'type': 'quantitative', 'scale': {'zero': True}}
            }
        }

    def test_histogram(self):
        recommendation = get_rec(spec_schema, {
            'encoding': [{'field': 'q1', 'bin': True, 'channel': 'x'}]
        }).to_vegalite()

        assert recommendation == {
            '$schema': 'https://vega.github.io/schema/vega-lite/v2.json',
            'data': {'url': 'data.csv'},
            'mark': 'bar',
            'encoding': {
                'x': {
                    'field': 'q1',
                    'type': 'quantitative',
                    'bin': {'maxbins': 10}
                },
                'y': {
                    'aggregate': 'count',
                    'type': 'quantitative',
                    'scale': {'zero': True}
                }
            }
        }

    def test_strip(self):
        recommendation = get_rec(spec_schema, {
            'encoding': [{'field': 'q1'}]
        }).to_vegalite()

        assert recommendation == {
            '$schema': 'https://vega.github.io/schema/vega-lite/v2.json',
            'data': {'url': 'data.csv'},
            'mark': 'tick',
            'encoding': {
                'x': {'field': 'q1', 'type': 'quantitative', 'scale': {'zero': True}}
            }
        }

class TestTypeChannel():
    def get_spec(self, t, channel):
        return {
            'mark': 'point',
            'encoding': {
                'y': {'field': 'q1', 'type': 'quantitative'},
                channel: {'field': 'q2' if t == 'quantitative' else 'o1', 'type': t}
            }
        }

    def test_q(self):
        comparisons = [('x', 'size'), ('size', 'color')]

        for c0, c1 in comparisons:
            a = run_spec(spec_schema, self.get_spec('quantitative', c0)).cost
            b = run_spec(spec_schema, self.get_spec('quantitative', c1)).cost

            assert a < b, f'Channel {c0} is not better than {c1}.'

    def test_o(self):
        comparisons = [('x', 'color'), ('color', 'size')]

        for c0, c1 in comparisons:
            a = run_spec(spec_schema, self.get_spec('ordinal', c0)).cost
            b = run_spec(spec_schema, self.get_spec('ordinal', c1)).cost

            assert a < b, f'Channel {c0} is not better than {c1}.'
