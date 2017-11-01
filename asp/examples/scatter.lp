% ====== Data definitions ======
fieldtype(horsepower,number).
cardinality(horsepower,94).

fieldtype(acceleration,number).
cardinality(acceleration,96).

% ====== Query constraints ======
encoding(e0).
field(e0,acceleration).

encoding(e1).
field(e1,horsepower).
