export const SCATTER: string = `% ====== Data definitions ======
data("cars.json").
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

export const HISTOGRAM: string = `% ====== Data definitions ======
data("cars.json").
num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

% ====== Query constraints ======
encoding(e0).
:- not field(e0,horsepower).
:- not bin(e0,_).
`;

export const STRIP: string = `% ====== Data definitions ======
data("cars.json").
num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

% ====== Query constraints ======
encoding(e0).
:- not type(e0,quantitative).
:- not field(e0,horsepower).
`;

export interface Example {
  name: string,
  program: string
}

const EXAMPLES: Array<Example> = [
  { name: 'scatter', program: SCATTER },
  { name: 'histogram', program: HISTOGRAM},
  { name: 'strip', program: STRIP}
];
export default EXAMPLES;
