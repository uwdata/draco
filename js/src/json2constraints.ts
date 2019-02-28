import { Constraint } from './constraints2json';

export interface ConstraintAsp {
  definitions: string;
  weights?: string;
  assigns?: string;
}

export default function json2constraints(json: Constraint[]): ConstraintAsp {
  const type = json[0].type;
  json.forEach(constraint => {
    if (constraint.type !== type) {
      throw new Error(`constraints not all of type ${type}`);
    }
  });

  let definitions = '';
  let weights;
  let assigns;
  if (type === 'soft') {
    weights = '';
    assigns = '';
  }

  for (const constraint of json) {
    const def = `% @constraint ${constraint.description}
${constraint.asp}`;
    definitions += def;
    definitions += '\n\n';

    if (type === 'soft') {
      const weight = `#const ${constraint.name}_weight = ${constraint.weight}.`;
      weights += weight;
      weights += '\n';

      const assign = `soft_weight(${constraint.name}, ${constraint.name}_weight).`;
      assigns += assign;
      assigns += '\n';
    }
  }

  if (type === 'hard') {
    return { definitions };
  } else {
    return {
      definitions,
      weights,
      assigns
    };
  }
}
