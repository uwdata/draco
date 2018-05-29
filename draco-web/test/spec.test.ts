import { asp2vl } from '../src/spec';

test('parses results correctly', () => {
  expect(asp2vl([
    'mark(bar)',

    'encoding(e0)',
    'channel(e0,x)',
    'field(e0,foo)',
    'type(e0,ordinal)',

    'encoding(e1)',
    'channel(e1,y)',
    'aggregate(e1,count)',
    'type(e1,quantitative)',
  ])).toBe({
    $schema: 'https://vega.github.io/schema/vega-lite/v2.json',
    data: {url: 'data/cars.json'},
    mark: 'bar',
    encoding: {
      x: { field: 'foo', type: 'ordinal' },
      y: { aggregate: 'count', type: 'quantitative' },
    },
  });
});
