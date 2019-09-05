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

  static fromVl(spec: TopLevelUnitSpec, name: string): FactsObject {
    return vl2facts(spec, name);
  }

  static toProgram(facts: FactsObject): string {
    return `${facts.join(".\n")}${".\n"}`;
  }
}

function vl2facts(spec: TopLevelUnitSpec, name: string): FactsObject {
  const facts = [`view(${name})`, `mark(${name},${spec.mark})`];

  const encoding = spec.encoding || {};

  let i = 1;
  for (const channel of Object.keys(encoding)) {
    const eid = `e${i}`;
    i += 1;
    facts.push(`encoding(${name},${eid})`);
    facts.push(`channel(${name},${eid},${channel})`);

    let encFieldType = null;
    let encZero = null;
    let encBinned = null;

    // translate encodings
    for (const field of Object.keys(encoding[channel])) {
      const fieldContent = encoding[channel][field];
      if (field === "type") {
        encFieldType = fieldContent;
        facts.push(`type(${name},${eid},${fieldContent})`);
      }
      if (field === "scale") {
        // translate two boolean fields
        let scale = null;
        if ("zero" in fieldContent) {
          scale = "zero";
        } else if ("log" in fieldContent) {
          scale = "log";
        }

        if (scale) {
          if (fieldContent[scale]) {
            facts.push(`scale(${name},${eid},${scale})`);
            encZero = fieldContent;
          } else {
            facts.push(`:- scale(${name},${eid},${scale})`);
          }
        }
      } else if (field === "bin") {
        encBinned = fieldContent;
        if (fieldContent) {
          facts.push(`bin(${name},${eid},true)`);
        } else {
          facts.push(`:- bin(${name},${eid},false)`);
        }
      } else if (field === "field") {
        // * is old vl for count
        if (fieldContent !== "*") {
          // fields can have spaces and start with capital letters
          facts.push(`field(${name},${eid},"${fieldContent}")`);
        }
      } else if (field === "aggregate") {
        facts.push(`aggregate(${name},${eid},${fieldContent})`);
      } else if (field === "stack") {
        facts.push(`stack(${name},${eid},${fieldContent})`);
        // translate normal fields
        // facts.push(`${field}(${name},${eid},${fieldContent})`);
      } else {
      }
    }

    if (
      encFieldType === "quantitative" &&
      encZero === null &&
      encBinned === null
    ) {
      facts.push(`scale(${name},${eid},zero)`);
    }
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
