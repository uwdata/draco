#script (python)

from clingo import Number, Function

def args(term):
    return [(Number(i),elem) for i,elem in enumerate(term.arguments)]

def name(term):
    return Function(term.name)

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
0 { encoding(C) } 1 :- single_channels(C).
{ encoding(C) } :- multi_channels(C).  % FIXME

% properties
{ type(E,T): types(T) } :- encoding(E).
{ agg(E,A): aggregates(A) } :- encoding(E).
{ bin(E,B): binning(B) } :- encoding(E).
{ scale(E,S): types(S) } :- encoding(E).
{ field(E,F): fields(F) } :- encoding(E).

% ====== Helpers ======

dimension(E) :- type(E,(n;o)).
dimension(E) :- bin(E,B), B != null.

% ====== Constraints ======

% === Within encodings ===

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
% :- encode(_,_,T,(sum;mean),_), T != q.

% min, max, and median only work for ordinal and quantitative
% :- encode(_,_,T,(min;max;median),_), T != q, T != o.
