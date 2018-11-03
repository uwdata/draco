import { cql2asp } from '../src';

test('generates correct asp', () => {
  expect(
    cql2asp({
      $schema: 'https://vega.github.io/schema/vega-lite/v3.json',
      data: { url: 'data/cars.json' },
      mark: 'bar',
      encodings: [
        { channel: 'x', field: 'foo', type: 'ordinal' },
        { channel: 'y', aggregate: 'count', type: 'quantitative', scale: { zero: true } },
      ],
    }).sort()
  ).toEqual(
    [
      'data("data/cars.json").',
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
    ].sort()
  );
  expect(
    cql2asp({
      $schema: 'https://vega.github.io/schema/vega-lite/v3.json',
      data: { url: 'data/cars.json' },
      mark: 'bar',
      encodings: [
        { channel: '?', field: 'foo', type: 'ordinal' },
        { channel: '?', aggregate: 'count', type: 'quantitative', scale: { zero: true } },
      ],
    }).sort()
  ).toEqual(
    [
      'data("data/cars.json").',
      'mark(bar).',

      'encoding(e0).',
      'field(e0,"foo").',
      'type(e0,ordinal).',

      'encoding(e1).',
      'aggregate(e1,count).',
      'type(e1,quantitative).',
      'zero(e1).',
    ].sort()
  );
  expect(
    cql2asp({
      $schema: 'https://vega.github.io/schema/vega-lite/v3.json',
      data: { url: 'data/cars.json' },
      mark: '?',
      encodings: [
        { channel: '?', field: 'foo', type: 'ordinal' },
        { channel: '?', aggregate: 'count', type: 'quantitative', scale: { zero: true } },
      ],
    }).sort()
  ).toEqual(
    [
      'data("data/cars.json").',

      'encoding(e0).',
      'field(e0,"foo").',
      'type(e0,ordinal).',

      'encoding(e1).',
      'aggregate(e1,count).',
      'type(e1,quantitative).',
      'zero(e1).',
    ].sort()
  );
});
