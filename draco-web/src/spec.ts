import { ChannelDef } from 'vega-lite/build/src/fielddef';
import { TopLevelFacetedUnitSpec, TopLevelSpec } from 'vega-lite/build/src/spec';

const REGEX = /(\w+)\(([\w\.\/]+)(,([\w\.]+))?\)/;

export function asp2vl(facts: string[]): TopLevelFacetedUnitSpec {
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
    if (enc.type === 'quantitative' && enc.zero === undefined) {
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
      ...(enc.bin !== undefined ? { bin: { maxbins: +enc.bin } } : {}),
      ...(Object.keys(scale).length ? { scale } : {}),
    };
  }

  return {
    $schema: 'https://vega.github.io/schema/vega-lite/v2.json',
    data: { url: `${url}` },
    mark,
    encoding,
  } as TopLevelFacetedUnitSpec;
}

/**
 * Get the array of witnesses from clingo output.
 * Return undefined if no witnesses were found.
 */
export function getModels(result: any) {
  return (result.Call || []).reduce((arr: any[], el: any) => {
    el.Witnesses.forEach((d: any) =>
      arr.push({
        facts: d.Value,
        costs: d.Costs,
      })
    );
    return arr;
  }, []);
}

export function models2vl(models: any[]) {
  return models.map(model => asp2vl(model.facts));
}

export function vl2asp(spec: TopLevelFacetedUnitSpec): string[] {
  const facts = [`mark(${spec.mark})`];

  if ('data' in spec && 'url' in spec.data) {
    facts.push(`data("${spec.data.url}")`);
  }

  const encoding = spec.encoding || {};

  let i = 0;
  for (const channel of Object.keys(encoding)) {
    const eid = `e${i++}`;
    facts.push(`encoding(${eid})`);
    facts.push(`channel(${eid},${channel})`);

    // translate encodings
    for (const field of Object.keys(encoding[channel])) {
      const fieldContent = encoding[channel][field];
      if (field === 'scale') {
        // translate two boolean fields
        if ('zero' in fieldContent) {
          if (fieldContent.zero) {
            facts.push(`zero(${eid})`);
          } else {
            facts.push(`:- zero(${eid})`);
          }
        }
        if ('log' in fieldContent) {
          if (fieldContent.log) {
            facts.push(`log(${eid})`);
          } else {
            facts.push(`:-log(${eid})`);
          }
        }
      } else if (field === 'bin') {
        facts.push(`${field}(${eid},${fieldContent.maxbins})`);
      } else if (field === 'field') {
        // fields can have spaces and start with capital letters
        facts.push(`${field}(${eid},"${fieldContent}")`);
      } else {
        // translate normal fields
        facts.push(`${field}(${eid},${fieldContent})`);
      }
    }
  }

  return facts;
}
