import 'jest';
import { Constraint, json2constraints } from '../src';
import { ConstraintAsp } from '../src/json2constraints';

test('generates constraint asp from json', () => {
  let input: Constraint[] = [
    {
      name: 'enc_type_valid',
      description: 'Primitive type has to support data type.',
      type: 'hard',
      asp:
        'hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).\nhard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).',
    },
  ];
  let output: ConstraintAsp = {
    definitions: `% @constraint Primitive type has to support data type.
hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).
hard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).

`,
  };
  expect(json2constraints(input)).toEqual(output);

  input = [
    {
      name: 'enc_type_valid',
      description: 'Primitive type has to support data type.',
      type: 'hard',
      asp:
        'hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).\nhard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).',
    },
    {
      name: 'bin_q_o',
      description: 'Can only bin quantitative or ordinal.',
      type: 'hard',
      asp: 'hard(bin_q_o,E,T) :- type(E,T), bin(E,_), T != quantitative, T != ordinal.',
    },
  ];

  output = {
    definitions: `% @constraint Primitive type has to support data type.
hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).
hard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).

% @constraint Can only bin quantitative or ordinal.
hard(bin_q_o,E,T) :- type(E,T), bin(E,_), T != quantitative, T != ordinal.

`,
  };
  expect(json2constraints(input)).toEqual(output);

  input = [
    {
      name: 'aggregate',
      description: 'Prefer to use raw (no aggregate).',
      type: 'soft',
      asp: 'soft(aggregate,E) :- aggregate(E,_).',
      weight: 1,
    },
  ];

  output = {
    definitions: `% @constraint Prefer to use raw (no aggregate).
soft(aggregate,E) :- aggregate(E,_).

`,
    weights: `#const aggregate_weight = 1.
`,
    assigns: `soft_weight(aggregate, aggregate_weight).
`
  };
  expect(json2constraints(input)).toEqual(output);

  input = [
    {
      name: 'aggregate',
      description: 'Prefer to use raw (no aggregate).',
      type: 'soft',
      asp: 'soft(aggregate,E) :- aggregate(E,_).',
      weight: 1,
    },
    {
      name: 'bin',
      description: 'Prefer to not bin.',
      type: 'soft',
      asp: 'soft(bin,E) :- bin(E,_).',
      weight: 2,
    },
  ];

  output = {
    definitions: `% @constraint Prefer to use raw (no aggregate).
soft(aggregate,E) :- aggregate(E,_).

% @constraint Prefer to not bin.
soft(bin,E) :- bin(E,_).

`,
    weights: `#const aggregate_weight = 1.
#const bin_weight = 2.
`,
    assigns: `soft_weight(aggregate, aggregate_weight).
soft_weight(bin, bin_weight).
`
  };

  expect(json2constraints(input)).toEqual(output);
});
