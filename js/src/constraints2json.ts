const RULE_REGEX = /%\s*@rule[\s\S]*?@end/g;
const CONSTRAINT_REGEX = /(?:%.*\n?)*([\s\S]*)\n%\s*@end/;
const ANNOTATION_REGEX = /%\s*@.*/g;
const TAG_REGEX = /%\s*@(\w+)\s+(.*)/;

const BRACED_REGEX = /{(.*)}/;

export interface Constraint {
  [s: string]: any
}

export default function constraints2json(constraints: string): Constraint[] {
  const result: Constraint[] = [];
  const rules = constraints.match(RULE_REGEX);

  if (!rules) {
    return result;
  }

  for (const rule of rules) {
    const annotations = rule.match(ANNOTATION_REGEX);

    const constraint = CONSTRAINT_REGEX.exec(rule);
    if (!annotations || !constraint) {
      throw Error(`unable to parse rule: ${rule}`)
    }

    const ruleObj = { constraint: constraint[1] };

    for (const line of annotations) {
      const extracted = TAG_REGEX.exec(line);
      
      if (!extracted) {
        continue;
      }

      const tag = extracted[1];
      const content = extracted[2];

      ruleObj[tag] = content;
    }

    processRuleObj(ruleObj);

    result.push(ruleObj);
  }

  return result;
}

function processRuleObj(ruleObj: { [s: string]: any }) {
  if (ruleObj.type) {
    const value = ruleObj.type;
    const extracted = BRACED_REGEX.exec(value);
    if (extracted) {
      ruleObj.type = extracted[1];
    }
  }

  if (ruleObj.weight) {
    const value = ruleObj.weight;

    const extracted = BRACED_REGEX.exec(value);
    if (extracted) {
      ruleObj.weight = parseInt(extracted[1], 10);
    }
  }

  if (ruleObj.type === 'constraint' && !ruleObj.weight) {
    ruleObj.weight = NaN
  }
}
