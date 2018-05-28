import Draco from './Draco';
export * from './constraints';

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
  const draco = new Draco('/node_modules/wasm-clingo');
  const status = await draco.init();

  const solution = draco.solve(EXAMPLE);

  console.log(solution);
}

// run draco
run();
