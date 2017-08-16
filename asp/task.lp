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
:- not mark(bar).

% encoding with field set and maybe with binning
encoding(e1).
:- not field(e1,n1).
0 {bin(e1,B): bin(B)} 1.

encoding(e2).
:- not field(e2,n2).
