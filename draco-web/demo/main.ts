import Draco from '../src/draco';

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

const draco = new Draco('https://cdn.jsdelivr.net/npm/wasm-clingo');
draco.init().then(() => {
  const solution = draco.solve(EXAMPLE);
  console.log(solution);
});
