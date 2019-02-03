import { TopLevelFacetedUnitSpec } from 'vega-lite/build/src/spec';

const REGEX = /(\w+)\(([\w\.\/]+)(,([\w\.]+))?(,([\w\.]+))?\)/;

const V_REGEX = /visualization\((.*)\)./;
/**
 * Convert from ASP to Vega-Lite.
 */
export default function asp2vl(facts: string[]): TopLevelFacetedUnitSpec[] {
  const visualizations = facts.filter(fact => {
    const extract = V_REGEX.exec(fact);
    return extract !== null;
  }).map(fact => {
    const extract = V_REGEX.exec(fact);
    return extract[1];
  });


  const result = visualizations.map(v => {
    return asp2vl_single(facts, v);
  });

  return result;
}

function asp2vl_single(facts: string[], v: string) {
  let mark = '';
  let url = 'data/cars.json'; // default dataset
  const encodings: { [enc: string]: any } = {};

  for (const value of facts) {
    // TODO: Better handle quoted fields. We currently simply remove all ".
    const cleanedValue = value.replace(/\"/g, '');
    const negSymbol = value.trim().startsWith(':-'); // TODO: remove this
    const [_, predicate, viz, __, first, ___, second] = REGEX.exec(cleanedValue) as any;

    if (viz !== v || predicate === 'visualization') {
      continue;
    }

    if (predicate === 'mark') {
      mark = first;
    } else if (predicate === 'data') {
      url = first;
    } else if (predicate !== 'soft') {
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
      ...(enc.bin !== undefined ? (+enc.bin === 10 ? { bin: true } : { bin: { maxbins: +enc.bin } }) : {}),
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
