import Draco from '../src';

const EXAMPLE = `
% ====== Data definitions ======
data("data/cars.json").
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

const draco = new Draco('https://unpkg.com/wasm-clingo@0.0.6');
draco.init().then(() => {
  const solution = draco.solve(EXAMPLE, {models: 5});
  console.log(solution);
});

