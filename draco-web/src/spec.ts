import { ChannelDef } from 'vega-lite/build/src/fielddef';
import { TopLevelFacetedUnitSpec } from 'vega-lite/build/src/spec';

const REGEX = /(\w+)\((\w+)(,(\w+))?\)/;

export function asp2vl(facts: any): TopLevelFacetedUnitSpec {
  let mark = '';
  const encodings: { [enc: string]: any } = {};

  for (const value of facts) {
    const [_, predicate, first, __, second] = REGEX.exec(value) as any;

    if (predicate === 'mark') {
      mark = first;
    } else if (predicate !== 'violation') {
      if (!encodings[first]) {
        encodings[first] = {}
      }

      encodings[first][predicate] = second || true;
    }
  }

  const encoding: { [channel: string]: any } = {};

  console.log(encodings)

  for (const e of Object.keys(encodings)) {
    const enc = encodings[e];

    console.log(e, enc)

    // if quantitative encoding and zero is not set, set zero to false
    if (enc.type === 'quantitative' && enc.zero === undefined) {
      enc.zero = false;
    }

    const scale = {
      ...(enc.log ? { type: 'log' } : {}),
      ...(enc.zero ? { zero: true } : {}),
    };

    encoding[enc.channel] = {
      type: enc.type,
      ...(enc.aggregate ? { aggregate: enc.aggregate } : {}),
      ...(enc.field ? { field: enc.field } : {}),
      ...(enc.stack ? { stack: enc.stack } : {}),
      ...(enc.bin ? { bin: { maxbins: enc.stack } } : {}),
      ...(Object.keys(scale).length ? { scale } : {}),
    };
  }

  return {
    $schema: 'https://vega.github.io/schema/vega-lite/v2.json',
    data: { url: 'data/cars.json' },
    mark,
    encoding,
  } as TopLevelFacetedUnitSpec;
}

/**
 * Get the array of witnesses from clingo output.
 * Return undefined if no witnesses were found.
 */
function getWitnesses(result: any): Array<{ Value: any[] }> {
  if (result.Call && result.Call.length > 0) {
    return result.Call[0].Witnesses;
  } else {
    return [];
  }
}

export function result2vl(result: any) {
  const witnesses = getWitnesses(result);
  return witnesses.map(witness => asp2vl(witness.Value));
}

export function vl2asp(spec: TopLevelFacetedUnitSpec): string[] {
  const facts = [`mark(${spec.mark}).`];

  let i = 0;
  for (const channel of Object.keys(spec)) {
    facts.push(`encoding(e${i})`);
    // TODO
    i++;
  }

  return facts;
}
