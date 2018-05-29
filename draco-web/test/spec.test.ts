import {asp2vl} from '../src/spec';

test('parses results correctly', () => {
  expect(asp2vl(['mark(bar)'])).toBe({
    mark: 'bar',
    encoding: {
      x: {field: 'foo', type: 'ordinal'},
      y: {aggregate: 'count', type: 'quantitative'}
    }
  });
});
