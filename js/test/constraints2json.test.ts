import 'jest';
import { constraints2json } from '../src';

test('generates correct json for constraints', () => {
  expect(
    constraints2json(`% @constraint Primitive type has to support data type.
hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).
hard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).
`)
  ).toEqual([
    {
      name: 'enc_type_valid',
      description: 'Primitive type has to support data type.',
      type: 'hard',
      asp: 'hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).\nhard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).',
    },
  ]);
  expect(
    constraints2json(`% @constraint Primitive type has to support data type.
hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).
hard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).

% @constraint Can only bin quantitative or ordinal.
hard(bin_q_o,E,T) :- type(E,T), bin(E,_), T != quantitative, T != ordinal.
`)
  ).toEqual([
    {
      name: 'enc_type_valid',
      description: 'Primitive type has to support data type.',
      type: 'hard',
      asp: 'hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).\nhard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).',
    },
    {
      name: 'bin_q_o',
      description: 'Can only bin quantitative or ordinal.',
      type: 'hard',
      asp: 'hard(bin_q_o,E,T) :- type(E,T), bin(E,_), T != quantitative, T != ordinal.',
    },
  ]);
  expect(
    constraints2json(
      `
% @constraint Prefer to use raw (no aggregate).
soft(aggregate,E) :- aggregate(E,_).
`,
      `
#const aggregate_weight = 1.
`
    )
  ).toEqual([
    {
      name: 'aggregate',
      description: 'Prefer to use raw (no aggregate).',
      type: 'soft',
      asp: 'soft(aggregate,E) :- aggregate(E,_).',
      weight: 1,
    },
  ]);
  expect(
    constraints2json(
      `
% @constraint Prefer to use raw (no aggregate).
soft(aggregate,E) :- aggregate(E,_).

% @constraint Prefer to not bin.
soft(bin,E) :- bin(E,_).
`,
      `
#const aggregate_weight = 1.
#const bin_weight = 2.
`
    )
  ).toEqual([
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
  ]);
});
