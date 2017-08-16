#script (python)

def min_preds(c,pred):
    """ Get the minimum of a constrant and the number of predicates. """
    return min([c.number, pred.number])

#end.

% ====== Definitions ======

marktype(point;bar;line;area;rule;symbol;text;tick).
type(q;o;n).
primitive_type(string;number;boolean).
aggregate(count;mean;median;min;max).
bin(3;5;10;100;200).
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

obj_id(0..@min_preds(max_encs,F)) :- F = {field(_)}.

1 { encoding(E): obj_id(E) }.

encoding(Id-1) :- encoding(Id), obj_id(Id), Id > 0.

% properties of encodings

% channel, field and type have to be present
{ channel(E,C): channel(C) } = 1 :- encoding(E).
{ field(E,F): field(F) } = 1 :- encoding(E).
{ type(E,T): type(T) } = 1 :- encoding(E).

% other properties that are not required
0 { aggregate(E,A): aggregate(A) } 1 :- encoding(E).
0 { bin(E,B): bin(B) } 1 :- encoding(E).
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
:- bin(E,_), aggregate(E,_).

% mean and sum only works for quantitative
:- aggregate(E,(sum;mean)), type(E,T), T != q.

% min, max, and median only work for ordinal and quantitative
:- aggregate(E,(min;max;median)), type(E,T), T != q, T != o.


% === Across encodings and between encodings and marks ===

% cannot use single channels twice
:- channel(E1, C), channel(E2, C), E1 != E2, single_channel(C).


% === Type checks ===

% fieldtype has to be primitive type
:- fieldtype(_,T), not primitive_type(T).

% check types of encoding properties
:- channel(_,C), not channel(C).
:- field(_,F), not field(F).
:- type(_,T), not type(T).
:- aggregate(_,A), not aggregate(A).
:- bin(_,B), not bin(B).
:- scale(_,S), not scale(S).


% ====== Preferences ======

% prefer quantitative > ordinal > nominal

% type weight
#const tw = 1.

:~ type(_,o). [1*tw@1]
:~ type(_,n). [2*tw@1]

% prefer to use raw (no aggregation)

% aggregation weight
#const aw = 1.

:~ aggregate(_,A), A != null. [aw@1]


% ====== Output ======
#show mark/1.

#show type/2.
#show channel/2.
#show field/2.
#show aggregate/2.
#show bin/2.
#show scale/2.
