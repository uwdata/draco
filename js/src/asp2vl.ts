import { TopLevelFacetedUnitSpec } from 'vega-lite/build/src/spec';

const REGEX = /(\w+)\(([\w\.\/]+)(,([\w\.]+))?\)/;

/**
 * Convert from ASP to Vega-Lite.
 */
export default function asp2vl(facts: string[]): TopLevelFacetedUnitSpec {
  let mark = '';
  let url = 'data/cars.json'; // default dataset
  const encodings: { [enc: string]: any } = {};

  for (const value of facts) {
    // TODO: Better handle quoted fields. We currently simply remove all ".
    const cleanedValue = value.replace(/\"/g, '');
    const negSymbol = value.trim().startsWith(':-'); // TODO: remove this
    const [_, predicate, first, __, second] = REGEX.exec(cleanedValue) as any;

    if (predicate === 'mark') {
      mark = first;
    } else if (predicate === 'data') {
      url = first;
    } else if (predicate !== 'violation') {
      if (!encodings[first]) {
        encodings[first] = {};
      }
      // if it contains the neg symbol, and the field is a boolean field, its value would be false
      // e.g., for the case ":- zero(e3)"
      encodings[first][predicate] = second || !negSymbol;
    }
  }

  const encoding: { [channel: string]: any } = {};

  for (const e of Object.keys(encodings)) {
    const enc = encodings[e];

    // if quantitative encoding and zero is not set, set zero to false
    if (enc.type === 'quantitative' && enc.zero === undefined && enc.bin === undefined) {
      enc.zero = false;
    }

    const scale = {
      ...(enc.log ? { type: 'log' } : {}),
      ...(enc.zero === undefined ? {} : enc.zero ? { zero: true } : { zero: false }),
    };

    encoding[enc.channel] = {
      type: enc.type,
      ...(enc.aggregate ? { aggregate: enc.aggregate } : {}),
      ...(enc.field ? { field: enc.field } : {}),
      ...(enc.stack ? { stack: enc.stack } : {}),
      ...(enc.bin !== undefined ? +enc.bin === 10 ? { bin: true} : { bin: { maxbins: +enc.bin } } : {}),
      ...(Object.keys(scale).length ? { scale } : {}),
    };
  }

  return {
    $schema: 'https://vega.github.io/schema/vega-lite/v3.json',
    data: { url: `${url}` },
    mark,
    encoding,
  } as TopLevelFacetedUnitSpec;
}
