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
mark(bar).

% encoding with field set and maybe with binning
encoding(e1).
field(e1,n1).
:- not bin(e1,_).

encoding(e2).
field(e2,n2).
