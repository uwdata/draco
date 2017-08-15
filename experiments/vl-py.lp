#script (python)

from clingo import parse_term

def concat(a, b):
    return parse_term("{}_{}".format(a.name, b.name))

#end.


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

:- not field(_,n1).
:- not field(_,n2).

% ====== Definitions ======

marktypes(point;bar;line;area;rule;symbol;text;tick).
types(q;o;n).
primitive_types(string;number;boolean).
aggregates(null;count;mean;median;min;max).
binning(null;3;5;10;100;200).
scales(null;zero;log).

% channels
single_channels(x;y;color;size;shape;text).
multi_channels(detail).
channel(C) :- single_channels(C).
channel(C) :- multi_channels(C).

fields(F) :- fieldtype(F,_).


% ====== Generate ======

% pick one marktype
{ mark(M) : marktypes(M) } = 1.

% encodings
0 { encoding(C,C,F): fields(F) } 1 :- single_channels(C).
{ encoding(@concat(C,F),C,F): fields(F) } :- multi_channels(C).

encoding(E) :- encoding(E,_,_).

% properties
field(E,F) :- encoding(E,_,F).
channel(E,C) :- encoding(E,C,_).
{ type(E,T): types(T) } = 1 :- encoding(E).
{ agg(E,A): aggregates(A) } = 1 :- encoding(E).
{ bin(E,B): binning(B) } = 1 :- encoding(E).
{ scale(E,S): types(S) } = 1 :- encoding(E).


% ====== Helpers ======

dimension(E) :- type(E,(n;o)).
dimension(E) :- bin(E,B), B != null.

% orientation for bars and ticks
orientation(horizontal) :- mark(bar;tick), type(E,(o;n)), channel(E,x).
orientation(vertical) :- mark(bar;tick), type(E,(o;n)), channel(E,y).

% ====== Constraints ======

% === Within Encodings ===

% primitive type has to support data type
:- type(E,q), field(E,F), fieldtype(F,(string;boolean)).

% can only bin quantitative
:- type(E,T), bin(E,B), B != null, T != q.

% do not use scale zero with dimension
:- scale(E,zero), dimension(E).

% do not use log scale with dimension
:- scale(E,log), dimension(E).

% cannot bin and aggregate
:- bin(E,B), agg(E,A), A != null, B != null.

% mean and sum only works for quantitative
:- agg(E,(sum;mean)), type(E,T), T != q.

% min, max, and median only work for ordinal and quantitative
:- agg(E,(min;max;median)), type(E,T), T != q, T != o.

% === Across encodings and between encodings and marks ===


% ====== Preferences ======

% prefer quantitative > ordinal > nominal

% type weight
#const tw = 1.

:~ type(_,o). [1*tw@1]
:~ type(_,n). [2*tw@1]

% prefer to use raw (no aggregation)

% aggregation weight
#const aw = 1.

:~ agg(_,A), A != null. [aw@1]

% ====== Output ======
#show mark/1.

#show type/2.
#show channel/2.
#show field/2.
#show agg/2.
#show bin/2.
#show scale/2.
