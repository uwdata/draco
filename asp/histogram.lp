% ====== Data definitions ======
fieldtype(horsepower,number).
cardinality(horsepower,94).

% ====== Query constraints ======
mark(bar).

encoding(e0).
channel(e0,x).
field(e0,horsepower).
:- not bin(e0,_).

encoding(e1).
channel(e1,y).
aggregate(e1,count).
