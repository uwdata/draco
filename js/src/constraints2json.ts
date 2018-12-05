import { errorBarSupportedChannels } from 'vega-lite/build/src/compositemark/errorbar';

interface Doc {
  description: string;
}

interface Asp {
  type: string;
  name: string;
  asp: string;
}

export interface Constraint extends Doc, Asp {
  weight?: number;
}

export default function constraints2json(constraintsAsp: string, weightsAsp?: string): Constraint[] {
  const constraints = constraintsAsp.match(CONSTRAINT_MATCH);
  if (!constraints) {
    throw Error('invalid constraints');
  }

  const result = constraints.map(
    (s: string): Constraint => {
      const doc = getDoc(s);
      const asp = getAsp(s);
      return {
        ...doc,
        ...asp,
      };
    }
  );

  if (weightsAsp) {
    const weights = weightsAsp.match(WEIGHTS_MATCH);
    const weightMap = getWeightMap(weights);

    if (!weights) {
      throw Error('invalid weights');
    }

    for (const constraint of result) {
      const name = constraint.name;
      constraint.weight = weightMap[name];
    }
  }

  return result;
}

function getDoc(s: string): Doc {
  const docMatch = s.match(DOC_MATCH);
  if (docMatch) {
    const docString = docMatch[0];
    const descriptionParts = DESCRIPTION_EXTRACT.exec(docString);

    if (descriptionParts) {
      return {
        description: descriptionParts[1],
      };
    }
  }

  return null;
}

function getAsp(s: string): Asp {
  const aspMatch = s.match(ASP_MATCH);
  if (aspMatch) {
    const asp = aspMatch.join('\n');
    const typeExtract = TYPE_EXTRACT.exec(asp);

    if (!typeExtract) {
      throw Error(`invalid asp: ${asp}`);
    }
    const type = typeExtract[1];

    const nameExtract = NAME_EXTRACT.exec(asp);
    if (!nameExtract) {
      throw Error(`invalid asp: ${asp}`);
    }
    const name = nameExtract[1];

    return {
      type,
      name,
      asp,
    };
  }
}

function getWeightMap(weights: string[]): { [s: string]: number } {
  const map = {};
  for (const weight of weights) {
    const nameExtract = WEIGHT_NAME_EXTRACT.exec(weight);
    if (!nameExtract) {
      throw Error(`invalid weight: ${weight}`);
    }
    const name = nameExtract[1];

    const valueExtract = WEIGHT_VALUE_EXTRACT.exec(weight);
    if (!valueExtract) {
      throw Error(`invalid weight: ${weight}`);
    }
    const value = +valueExtract[1];

    map[name] = value;
  }

  return map;
}

const CONSTRAINT_MATCH = /%\s*@constraint(?:(.+)\n)+/g;
const DOC_MATCH = /(%.*\n)+/g;
const DESCRIPTION_EXTRACT = /@constraint\s+(.*)/;
const ASP_MATCH = /^[^%].*/gm;
const TYPE_EXTRACT = /(\w+)\(/;
const NAME_EXTRACT = /\((\w+),.*\)/;

const WEIGHTS_MATCH = /#const.*/g;
const WEIGHT_NAME_EXTRACT = /#const\s+(\w+?)_weight/;
const WEIGHT_VALUE_EXTRACT = /=\s*(\d+)/;
