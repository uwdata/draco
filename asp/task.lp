% ====== Data definitions ======

fieldtype(s1,string).
cardinality(s1,10).

fieldtype(s2,string).
cardinality(s2,3).

fieldtype(n1,number).
cardinality(n1,12).

fieldtype(n2,number).
cardinality(n2,100).

% ====== Query constraints ======

% use certain mark
% :- not mark(bar).

:- not 1 = { encoding(E): channel(E,x), type(E,q) }.
:- not 1 = { encoding(E): channel(E,y), type(E,q), bin(E,_) }.

% :- not field(_,n1).
% :- not field(_,n2).
