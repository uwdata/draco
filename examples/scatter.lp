% ====== Data definitions ======
num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

fieldtype(acceleration,number).
cardinality(acceleration,96).

% ====== Query constraints ======
view(view1).

encoding(view1,e0).
:- not field(view1,e0,acceleration).

encoding(view1,e1).
:- not field(view1,e1,horsepower).

