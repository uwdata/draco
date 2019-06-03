import { ConstraintDictionary } from '../../../src';

describe('ConstraintDictionary', () => {
  describe('ASP to ConstraintDictionary', () => {
    test('Parses ASP to ConstraintDictionary correctly (soft)', () => {
      expect(
        ConstraintDictionary.fromAsp(SOFT_CONSTRAINTS.prefAsp, SOFT_CONSTRAINTS.weightAsp)
      ).toEqual(SOFT_CONSTRAINTS.constraintDictionary);
    });

    test('Parses ASP to ConstraintDictionary correctly (hard)', () => {
      expect(ConstraintDictionary.fromAsp(HARD_CONSTRAINTS.prefAsp)).toEqual(
        HARD_CONSTRAINTS.constraintDictionary
      );
    });
  });
});

const SOFT_CONSTRAINTS = {
  prefAsp: `% @constraint description1
soft(subtype,name1,view,parameters) :- definition(one).
soft(subtype,name1,view,parameters) :- definition(one).

% @constraint description2
soft(subtype,name2,view,parameters) :- definition(two).
`,
  weightAsp: `soft_weight(subtype,name1,1).
soft_weight(subtype,name2,2).`,

  constraintDictionary: {
    'soft-subtype-name1': {
      type: 'soft',
      description: 'description1',
      subtype: 'subtype',
      name: 'name1',
      view: 'view',
      parameters: 'parameters',
      definitions: ['definition(one).', 'definition(one).'],
      weight: 1,
    },
    'soft-subtype-name2': {
      type: 'soft',
      description: 'description2',
      subtype: 'subtype',
      name: 'name2',
      view: 'view',
      parameters: 'parameters',
      definitions: ['definition(two).'],
      weight: 2,
    },
  },
};

const HARD_CONSTRAINTS = {
  prefAsp: `% @constraint description1
hard(subtype,name1,view,parameters) :- definition(one).
hard(subtype,name1,view,parameters) :- definition(one).

% @constraint description2
hard(subtype,name2,view,parameters) :- definition(two).
`,

  constraintDictionary: {
    'hard-subtype-name1': {
      type: 'hard',
      description: 'description1',
      subtype: 'subtype',
      name: 'name1',
      view: 'view',
      parameters: 'parameters',
      definitions: ['definition(one).', 'definition(one).'],
    },
    'hard-subtype-name2': {
      type: 'hard',
      description: 'description2',
      subtype: 'subtype',
      name: 'name2',
      view: 'view',
      parameters: 'parameters',
      definitions: ['definition(two).'],
    },
  },
};
