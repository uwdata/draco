% ====== Data definitions ======
num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

% ====== Query constraints ======
encoding(e0).
:- not type(e0,quantitative).
:- not field(e0,horsepower).
