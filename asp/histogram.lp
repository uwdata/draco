% ====== Data definitions ======
fieldtype(horsepower,number).
cardinality(horsepower,94).

% ====== Query constraints ======
:- not mark(bar).

encoding(e0).
:- not channel(e0,x).
:- not field(e0,horsepower).
:- not bin(e0,_).

encoding(e1).
:- not channel(e1,y).
:- not aggregate(e1,count).
