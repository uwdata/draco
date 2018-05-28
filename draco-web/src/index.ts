import Draco from './Draco';

const EXAMPLE = `
% ====== Data definitions ======
num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

fieldtype(acceleration,number).
cardinality(acceleration,96).

% ====== Query constraints ======
encoding(e0).
:- not field(e0,acceleration).

encoding(e1).
:- not field(e1,horsepower).
`;

export default async function run() {
  const draco = new Draco();
  const status = await draco.init('http://localhost:8000/node_modules/wasm-clingo');

  const solution = await draco.solve(EXAMPLE, { constraints: 'all' });

  console.log(solution);
}

// run draco
run();
