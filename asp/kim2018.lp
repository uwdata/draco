% only three encodings
3 { encoding(E): encoding(E) } 3.

% two quantitative, one nominal
2 { type(E,quantitative): encoding(E) } 2.
1 { type(E,nominal): encoding(E) } 1.
:- type(_,ordinal).

% need to use x and y
:- not channel(_,(x;y)).

% only scatterplots
:- not mark(point).

% always use zero for quantitative
:- type(E,quantitative), not zero(E).

% no aggregations
:- aggregate(E,_).

% no binning
:- bin(E,_).

% no column
:- channel(E,column).

% no shape
:- channel(E,shape).
