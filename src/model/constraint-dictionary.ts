import {
  Constraint,
  ConstraintObject,
  HardConstraintObject,
  SoftConstraintObject,
} from './constraint';
import { doesMatchRegex } from './util';

export type ConstraintDictionaryObject = { [name: string]: ConstraintObject };
export type SoftConstraintDictionaryObject = { [name: string]: SoftConstraintObject };
export type HardConstraintDictionaryObject = { [name: string]: HardConstraintObject };

export class ConstraintDictionary {
  static isSoftConstraintDictionary(
    dict: ConstraintDictionaryObject
  ): dict is SoftConstraintDictionaryObject {
    if (Object.entries(dict).length === 0) {
      return false;
    }

    const [firstName, firstConstraint] = Object.entries(dict)[0];
    return Constraint.isSoftConstraint(firstConstraint);
  }

  static isHardConstraintDictionary(
    dict: ConstraintDictionaryObject
  ): dict is SoftConstraintDictionaryObject {
    if (Object.entries(dict).length === 0) {
      return false;
    }

    const [firstName, firstConstraint] = Object.entries(dict)[0];
    return Constraint.isHardConstraint(firstConstraint);
  }

  static fromAsp(prefAsp: string, weightAsp?: string): ConstraintDictionaryObject {
    const prefMatches = doesMatchRegex(prefAsp, PREF_REGEX);

    let weightDictionary;
    if (!!weightAsp) {
      const weightMatches = doesMatchRegex(weightAsp, WEIGHT_REGEX);
      if (!weightMatches) {
        throw new Error(`Weight ASP: ${weightAsp} does not match weight regex.`);
      }

      const singleWeightAsps = weightAsp.match(WEIGHT_REGEX);
      weightDictionary = singleWeightAsps.reduce(
        (dict, asp) => {
          const [fullMatch, subtype, name, weight] = WEIGHT_REGEX.exec(asp);
          WEIGHT_REGEX.lastIndex = 0;

          const uniqueName = `soft-${subtype}-${name}`;
          dict[uniqueName] = +weight;

          return dict;
        },
        {} as any
      );
    }

    if (!prefMatches) {
      throw new Error(`Pref ASP: ${prefMatches} does not match pref regex.`);
    }

    const singlePrefAsps = prefAsp.match(PREF_REGEX);
    const result = singlePrefAsps.reduce(
      (dict, asp) => {
        const constraint = Constraint.fromPrefAsp(asp);
        const uniqueName = Constraint.getUniqueName(constraint);

        if (!!weightDictionary) {
          (constraint as SoftConstraintObject).weight = weightDictionary[uniqueName];
        }

        dict[uniqueName] = constraint;
        return dict;
      },
      {} as ConstraintDictionaryObject
    );

    return result;
  }
}

const PREF_REGEX = /%\s*@constraint(?:(?:.+)\n?)+/g;
const WEIGHT_REGEX = /soft_weight\((\w+),(\w+),(\d+)\).*/g;
