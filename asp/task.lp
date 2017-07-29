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

% want to use number as ordinal
%% :- not encode(_,n1,o).

:- not encode(_,n1,_).
:- not encode(_,n2,_).