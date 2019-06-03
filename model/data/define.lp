fieldtype(F,T) :- fieldtype(F,T).
extent(F,MIN,MAX) :- extent(F,MIN,MAX).
cardinality(F,C) :- cardinality(F,C).
num_rows(S) :- num_rows(S).

% optional
cardinality(0,0) :- #false.
num_rows(0) :- #false.
extent(0,0,0) :- #false.

