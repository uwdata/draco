import { Constraint } from './constraints2json';

const NAME_REGEX = /violation\((\w+).*?\)/;

export default function json2constraints(constraints: Constraint[]):  { [s: string]: string } {
  const result: { [s: string]: string[] } = {
    generate: [],
    soft: [],
    weights: [],
    assignWeights: [],
    hard: [],
    define: []
  };

  for (const constraint of constraints) {
    const rule = [];

    let constraintAsp;
    for (const key of Object.keys(constraint)) {
      const value = constraint[key];

      switch (key) {
        case 'constraint':
          {
            constraintAsp = value;
          }
          break;
        case 'type':
          {
            rule.unshift(`% @${key} {${value}}`);
          }
          break;
        case 'weight':
          {
            rule.push(`% @${key} {${value}}`);
          }
          break;
        default:
          {
            rule.push(`% @${key} ${value}`);
          }
      }
    }

    rule.unshift('% @rule');
    rule.push(constraintAsp);
    rule.push('% @end');

    const ruleAsp = rule.join('\n');
    switch (constraint.type) {
      case 'violation':
        {
          if (!isNaN(constraint.weight)) {  // soft
            const match = NAME_REGEX.exec(constraint.constraint);
            if (!match) {
              const msg = `invalid violation: ${constraint.constraint}`;
              throw Error(msg);
            }
            const name = match[1];
            const weightDecl = `#const ${name}_weight = ${constraint.weight}.`
            result.weights.push(weightDecl);
            const weightAssign = `violation_weight(${name},${name}_weight).`;
            result.assignWeights.push(weightAssign);

            result.soft.push(ruleAsp);
          } else {  // hard
            result.hard.push(ruleAsp);
          }
        }
        break;
      default:
        result[constraint.type].push(ruleAsp);
    }
  }

  const asp = {};
  for (const key of Object.keys(result)) {
    if (result[key].length === 0) {
      delete result[key];
    } else {
      switch (key) {
        case 'weights':
        case 'assignWeights':
          result[key].unshift('% ==== GENERATED FILE // DO NOT MODIFY ====')
          asp[key] = result[key].join('\n');
          break;
        default:
          asp[key] = result[key].join('\n\n');
      }
    }
  }

  return asp;
}