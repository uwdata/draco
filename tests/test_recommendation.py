from draco.run import run
from draco.spec import Data, Task, Query, Field
import unittest

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
        Field('n1', 'string', 5, 1)
    ], 100, url='data.csv')

class TestSpecs():
    def test_scatter(self):
        recommendation = get_rec(spec_schema, {
            'encoding': [{'field': 'q1'}, {'field': 'q2'}]
        }).to_vegalite()

        assert recommendation == {
            '$schema': 'https://vega.github.io/schema/vega-lite/v2.0.json',
            'data': {'url': 'data.csv'},
            'mark': 'point',
            'encoding': {
                'x': {'field': 'q1', 'type': 'quantitative', 'scale': {'zero': True}},
                'y': {'field': 'q2', 'type': 'quantitative', 'scale': {'zero': True}}
            }
        }

    @unittest.skip("not working yet")
    def test_histogram(self):
        recommendation = get_rec(spec_schema, {
            'encoding': [{'field': 'q1', 'bin': True}]
        }).to_vegalite()

        assert recommendation == {
            '$schema': 'https://vega.github.io/schema/vega-lite/v2.0.json',
            'data': {'url': 'data.csv'},
            'mark': 'bar',
            'encoding': {
                'x': {'field': 'q1', 'type': 'quantitative', 'bin': {'maxbins': 10}},
                'y': {'aggregate': 'count', 'type': 'quantitative', 'scale': {'zero': True}}
            }
        }

    @unittest.skip("not working yet")
    def test_strip(self):
        recommendation = get_rec(spec_schema, {
            'encoding': [{'field': 'q1'}]
        }).to_vegalite()

        assert recommendation == {
            '$schema': 'https://vega.github.io/schema/vega-lite/v2.0.json',
            'data': {'url': 'data.csv'},
            'mark': 'tick',
            'encoding': {
                'x': {'field': 'q1', 'type': 'quantitative'}
            }
        }

class TestTypeChannel():
    def get_spec(self, channel):
        return {
            'mark': 'point',
            'encoding': {
                channel: {'field': 'q1', 'type': 'quantitative'}
            }
        }

    def test_q(self):
        a = run_spec(spec_schema, self.get_spec('x')).cost
        b = run_spec(spec_schema, self.get_spec('color')).cost

        assert a < b
