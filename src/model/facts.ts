import { TopLevelUnitSpec } from "vega-lite/src/spec/unit";
import { doesMatchRegex } from "./util";

export type VegaLiteSpecDictionaryObject = { [name: string]: TopLevelUnitSpec };

export type FactsObject = string[];

export class Facts {
  static toVegaLiteSpecDictionary(
    facts: FactsObject
  ): VegaLiteSpecDictionaryObject {
    const cleanedFacts = facts.map(fact => {
      const cleaned = fact.replace(/\"/g, "");
      return cleaned;
    });
    return facts2vl(cleanedFacts);
  }

  static toViews(facts: FactsObject): string[] {
    return facts2views(facts);
  }

  static getHardViolations(facts: FactsObject): FactsObject {
    return facts.filter(f => doesMatchRegex(f, /hard\(.*/));
  }

  static getSoftViolations(facts: FactsObject): FactsObject {
    return facts.filter(f => doesMatchRegex(f, /soft\(.*/));
  }

  static getViewFacts(facts: FactsObject): FactsObject {
    return facts.filter(f => doesMatchRegex(f, /view_fact\(.*/));
  }

  static fromYH(yh: any): { negative: FactsObject; positive: FactsObject } {
    let facts = [];

    const fields = yhFields(yh.fields);
    facts = facts.concat(fields);

    const rows = `num_rows(${yh.num_rows})`;
    facts.push(rows);

    const task = `task(${yh.task})`;
    facts.push(task);

    const neg = yhSpec(yh.negative, "v1");
    const negative = facts.concat(neg);

    const pos = yhSpec(yh.positive, "v2");
    const positive = facts.concat(pos);

    return { negative, positive };
  }
}

function yhSpec(spec: any, name: string) {
  const facts = [];

  facts.push(`view(${name})`);
  facts.push(`mark(${name},point)`);

  const encoding = spec.encoding;

  let i = 0;
  for (const channel of Object.keys(encoding)) {
    const enc = encoding[channel];

    const e = `e${i}`;
    facts.push(`encoding(${name},${e})`);
    facts.push(`channel(${name},${e},${channel})`);
    facts.push(`field(${name},${e},${enc.field})`);
    facts.push(`type(${name},${e},${enc.type})`);
    if (enc.scale) {
      facts.push(`scale(${name},${e},zero)`);
    }
    i += 1;
  }

  return facts;
}

function yhFields(fields: any[]) {
  const facts = [];

  for (const field of fields) {
    facts.push(`fieldtype(${field.name},${field.type})`);

    const entropy = field.entropy > 1 ? "high" : "low";
    facts.push(`entropy(${field.name},${entropy})`);

    facts.push(`cardinality(${field.name},${field.cardinality})`);
    facts.push(`interesting(${field.name},${field.interesting})`);
  }
  return facts;
}

const VIEW_REGEX_CAPTURE = /view\((.*)\)/;
const FACT_REGEX = /(\w+)\(([\w\.\/]+)(,([\w\.]+))?(,([\w\.]+))?\)/;

function facts2vl(facts: string[]): VegaLiteSpecDictionaryObject {
  const views = facts2views(facts);

  const result = views.reduce(
    (dict, v) => {
      dict[v] = facts2vl_single(facts, v);
      return dict;
    },
    {} as any
  );

  return result;
}

function facts2views(facts: string[]): string[] {
  const views = facts
    .filter(fact => {
      return doesMatchRegex(fact, VIEW_REGEX_CAPTURE);
    })
    .map(fact => {
      const extract = VIEW_REGEX_CAPTURE.exec(fact);
      if (extract) {
        const [_, name] = extract;
        return name;
      }
      throw new Error(`Invalid view statement: ${fact}.`);
    });

  return views;
}

function facts2vl_single(facts: string[], view: string): TopLevelUnitSpec {
  let mark;
  const encodings: { [enc: string]: any } = {};

  for (const value of facts) {
    const extract = FACT_REGEX.exec(value);
    if (!extract) {
      continue;
    }

    const [_, predicate, viz, __, first, ___, second] = extract;

    if (viz !== view) {
      continue;
    }

    if (predicate === "view") {
      continue;
    }

    switch (predicate) {
      case "mark":
        mark = first;
        break;
      case "field":
      case "type":
      case "channel":
      case "scale":
      case "bin":
      case "aggregate":
      case "stack":
        if (!encodings[first]) {
          encodings[first] = {};
        }

        encodings[first][predicate] = second;
    }
  }

  const encoding: { [channel: string]: any } = {};

  for (const e of Object.keys(encodings)) {
    const enc = encodings[e];

    const scale = {
      ...(enc.scale === "log" ? { type: "log" } : {}),
      ...(enc.scale === "zero" ? { zero: true } : {})
    };

    const insert = {
      type: enc.type,
      ...(enc.aggregate ? { aggregate: enc.aggregate } : {}),
      ...(enc.field ? { field: enc.field } : {}),
      ...(enc.stack ? { stack: enc.stack } : {}),
      ...(enc.bin ? { bin: JSON.parse(enc.bin) } : {}),
      ...(enc.scale ? { scale } : {})
    };

    if (enc.aggregate) {
      encoding;
    }

    encoding[enc.channel] = insert;
  }

  const spec = {
    mark,
    encoding
  } as TopLevelUnitSpec;

  return spec;
}
