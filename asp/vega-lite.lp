#script (python)

from clingo import parse_term

def concat(*args):
    return parse_term("_".join(map(str, args)))

def min_preds(c,pred):
    """ Get the minimum of a constrant and the number of predicates. """
    return min([c.number, pred.number])

#end.

% ====== Definitions ======

marktype(point;bar;line;area;rule;symbol;text;tick).
type(q;o;n).
primitive_type(string;number;boolean).
aggregate(count;mean;median;min;max).
binning(3;5;10;100;200).
scale(zero;log).

% channels
single_channel(x;y;color;size;shape;text).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).

field(F) :- fieldtype(F,_).


% ====== Generate ======

% pick one marktype
{ mark(M) : marktype(M) } = 1.

% encodings

% maximum number for each multi channel encoding
#const max_encs = 5.

obj_cnt(0..@min_preds(max_encs,F)) :- F = {field(_)}.

% here we generate encodings and by splitting channels for which there can only be one encoding and for which there can be multiple
% this reduces the size of the grounded program
0 { unique_encoding(C) } 1 :- single_channel(C).
{ multi_encoding(C,Cnt): obj_cnt(Cnt) } :- multi_channel(C).

multi_encoding(C,Cnt-1) :- multi_encoding(C,Cnt), obj_cnt(Cnt), Cnt > 0, multi_channel(C).

% properties of encodings

% get the channel from unique_encoding and multi_encoding
channel(C,C) :- unique_encoding(C).
channel(@concat(C,Cnt),C) :- multi_encoding(C,Cnt).

encoding(E) :- channel(E,_).

% field and type have to be present
{ field(E,F): field(F) } = 1 :- encoding(E).
{ type(E,T): type(T) } = 1 :- encoding(E).

% other properties that are not required
0 { agg(E,A): aggregate(A) } 1 :- encoding(E).
0 { bin(E,B): binning(B) } 1 :- encoding(E).
0 { scale(E,S): scale(S) } 1 :- encoding(E).


% ====== Helpers ======

dimension(E) :- type(E,(n;o)).
dimension(E) :- bin(E,_).

% orientation for bars and ticks
orientation(horizontal) :- mark(bar;tick), type(E,(o;n)), channel(E,x).
orientation(vertical) :- mark(bar;tick), type(E,(o;n)), channel(E,y).

% ====== Constraints ======

% === Within Encodings ===

% primitive type has to support data type
:- type(E,q), field(E,F), fieldtype(F,(string;boolean)).

% can only bin quantitative
:- type(E,T), bin(E,_), T != q.

% do not use scale zero with dimension
:- scale(E,zero), dimension(E).

% do not use log scale with dimension
:- scale(E,log), dimension(E).

% cannot bin and aggregate
:- bin(E,_), agg(E,_).

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
