% ====== Data definitions ======
num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

% ====== Query constraints ======
encoding(e0).
:- not field(e0,horsepower).
:- not bin(e0,_).
