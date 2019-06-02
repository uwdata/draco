import { doesMatchRegex } from './util';

export interface ConstraintObject {
  type: ConstraintType;
  subtype: string;
  name: string;
  view: string;
  parameters: string;
  description: string;
  definitions: string[];
}

export interface HardConstraintObject extends ConstraintObject {}

export interface SoftConstraintObject extends ConstraintObject {
  weight?: number;
}

export class Constraint {
  static HARD_TYPE: 'hard' = 'hard';
  static SOFT_TYPE: 'soft' = 'soft';

  static isHardConstraint(constraint: ConstraintObject): constraint is HardConstraintObject {
    return constraint.type === Constraint.HARD_TYPE;
  }

  static isSoftConstraint(constraint: ConstraintObject): constraint is SoftConstraintObject {
    return constraint.type === Constraint.SOFT_TYPE;
  }

  static getUniqueName(constraint: ConstraintObject): string {
    return `${constraint.type}-${constraint.subtype}-${constraint.name}`;
  }

  static fromPrefAsp(asp: string): ConstraintObject {
    const matches = doesMatchRegex(asp, PREF_ASP_REGEX);
    if (!matches) {
      throw new Error(`ASP (${asp}) does not match constraint regex.`);
    }

    const [
      fullMatch,
      description,
      code,
      type,
      subtype,
      name,
      view,
      parameters,
    ] = PREF_ASP_REGEX.exec(asp);

    const definitions = code
      .trim()
      .split('\n')
      .map(line => {
        const [fullMatch, definition] = PREF_DEFINITION_REGEX.exec(line);
        return definition;
      });

    return {
      subtype,
      name,
      view,
      parameters,
      description,
      definitions,
      type: type as ConstraintType,
    };
  }

  static toPrefAsp(c: ConstraintObject): string {
    const description = `% @constraint ${c.description}`;
    const head = `${c.type}(${c.subtype},${c.name},${c.view},${c.parameters})`;
    const code = c.definitions
      .map(def => {
        return `${head} :- ${def}`;
      })
      .join('\n')
      .trim();

    return `${description}\n${code}`;
  }
}

export type ConstraintType = typeof Constraint.HARD_TYPE | typeof Constraint.SOFT_TYPE;

const PREF_ASP_REGEX = /%\s*@constraint (.*)\n((?:(hard|soft)\((\w+),(\w+),(\w+),(\w+)\).*\n?)+)/;
const PREF_DEFINITION_REGEX = /:-\s*(.*)/;
