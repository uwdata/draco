import Draco from './Draco';

const draco = new Draco();

draco.init('http://localhost:8000/node_modules/wasm-clingo', (status: string) => {
  console.log(status);
}).then(() => {
  call();
});

function call() {
  const example = `
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
    `

  const options = {
    constraints: 'all'
  };

  draco.solve(example, options).then((solution: Object) => {
    console.log(solution);
  });
}

export default Draco;
