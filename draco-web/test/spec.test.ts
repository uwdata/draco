import { asp2vl, vl2asp } from '../src/spec';
import { aspSpecs, vlSpecs } from './specs';

test('bidirectional_test', () => {
  for (let i = 0; i < vlSpecs.length; i++) {
    const aspSpec = aspSpecs[i];
    const vlSpec = vlSpecs[i];
    expect([asp2vl(aspSpec), vl2asp(vlSpec).sort()]).toEqual([vlSpec, aspSpec.sort()]);
  }
});

test('parses results correctly', () => {
  expect(
    asp2vl([
      'mark(bar)',

      'encoding(e0)',
      'channel(e0,x)',
      'field(e0,"foo")',
      'type(e0,ordinal)',

      'encoding(e1)',
      'channel(e1,y)',
      'aggregate(e1,count)',
      'type(e1,quantitative)',
      'zero(e1)',
    ])
  ).toEqual({
    $schema: 'https://vega.github.io/schema/vega-lite/v2.json',
    data: { url: 'data/cars.json' },
    mark: 'bar',
    encoding: {
      x: { field: 'foo', type: 'ordinal' },
      y: { aggregate: 'count', type: 'quantitative', scale: { zero: true } },
    },
  });
});

test('generates correct asp', () => {
  expect(
    vl2asp({
      $schema: 'https://vega.github.io/schema/vega-lite/v2.json',
      data: { url: 'data/cars.json' },
      mark: 'bar',
      encoding: {
        x: { field: 'foo', type: 'ordinal' },
        y: { aggregate: 'count', type: 'quantitative', scale: { zero: true } },
      },
    }).sort()
  ).toEqual(
    [
      'data("data/cars.json")',
      'mark(bar)',

      'encoding(e0)',
      'channel(e0,x)',
      'field(e0,"foo")',
      'type(e0,ordinal)',

      'encoding(e1)',
      'channel(e1,y)',
      'aggregate(e1,count)',
      'type(e1,quantitative)',
      'zero(e1)',
    ].sort()
  );
});
