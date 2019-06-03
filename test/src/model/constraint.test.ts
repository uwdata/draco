import { Constraint, ConstraintObject } from '../../../src';

describe('Constraint Tests', () => {
  describe('ASP to Constraint', () => {
    test('soft constraint', () => {
      expect(Constraint.fromPrefAsp(SOFT_CONSTRAINT.asp)).toEqual(SOFT_CONSTRAINT.constraintObject);
    });

    test('Parses ASP to ConstraintObject correctly (hard)', () => {
      expect(Constraint.fromPrefAsp(HARD_CONSTRAINT.asp)).toEqual(HARD_CONSTRAINT.constraintObject);
    });
  });

  describe('Constraint to ASP', () => {
    test('Parses ConstraintObject to ASP correctly', () => {
      expect(Constraint.toPrefAsp(SOFT_CONSTRAINT.constraintObject)).toEqual(SOFT_CONSTRAINT.asp);
    });

    test('Parses ConstraintObject to ASP correctly', () => {
      expect(Constraint.toPrefAsp(HARD_CONSTRAINT.constraintObject)).toEqual(HARD_CONSTRAINT.asp);
    });
  });
});

const SOFT_CONSTRAINT = {
  asp: `% @constraint description
soft(subtype,name,view,parameters) :- definition(here).
soft(subtype,name,view,parameters) :- definition(there).`,
  constraintObject: {
    type: 'soft',
    description: 'description',
    subtype: 'subtype',
    name: 'name',
    view: 'view',
    parameters: 'parameters',
    definitions: ['definition(here).', 'definition(there).'],
  } as ConstraintObject,
};

const HARD_CONSTRAINT = {
  asp: `% @constraint description
hard(subtype,name,view,parameters) :- definition(here).
hard(subtype,name,view,parameters) :- definition(there).`,
  constraintObject: {
    type: 'hard',
    description: 'description',
    subtype: 'subtype',
    name: 'name',
    view: 'view',
    parameters: 'parameters',
    definitions: ['definition(here).', 'definition(there).'],
  } as ConstraintObject,
};
