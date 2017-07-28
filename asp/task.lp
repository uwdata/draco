% ====== Data definitions ======

fieldtype(s1,string).
fieldtype(s2,string).

fieldtype(n1,number).
fieldtype(n2,number).

% ====== Query constraints ======

% use certain mark
% :- not mark(bar).

% want to use number as ordinal
%% :- not encode(_,n1,o).

:- not encode(_,n1,_).
:- not encode(_,n2,_).