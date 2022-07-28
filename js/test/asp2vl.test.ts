import 'jest';
import { asp2vl } from '../src';

test('parses results correctly', () => {
  expect(
    asp2vl([
      'mark(bar).',

      'encoding(e0).',
      'channel(e0,x).',
      'field(e0,"foo").',
      'type(e0,ordinal).',

      'encoding(e1).',
      'channel(e1,y).',
      'aggregate(e1,count).',
      'type(e1,quantitative).',
      'zero(e1).',
    ])
  ).toEqual({
    $schema: 'https://vega.github.io/schema/vega-lite/v5.json',
    data: { url: 'data/cars.json' },
    mark: 'bar',
    encoding: {
      x: { field: 'foo', type: 'ordinal' },
      y: { aggregate: 'count', type: 'quantitative', scale: { zero: true } },
    },
  });
});
