% ====== Data definitions ======
data("cars.csv").

num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

fieldtype(acceleration,number).
cardinality(acceleration,96).

% ====== Visualization specification ======

mark(point).

encoding(e0).
field(e0,acceleration).
channel(e0,x).
type(e0,quantitative).
zero(e0).

encoding(e1).
field(e1,horsepower).
channel(e1,y).
type(e1,quantitative).
zero(e1).
