% ====== Generators ======

% encodings

% maximum number for each multi channel encoding
#const max_extra_encs = 1.

obj_id(1..max_extra_encs).

{ encoding(V,E): obj_id(E) } :- visualization(V).

:- not encoding(V,ID), encoding(V,ID-1), obj_id(ID), obj_id(ID-1).

% don't add extra field
:- encoding(V,ID), obj_id(ID), field(V,ID,F).

% properties of encodings

% channel and type have to be present
{ channel(V,E,C) : channel(C) } = 1 :- encoding(V,E).
{ type(V,E,T): type(T) } = 1 :- encoding(V,E).

% other properties that are not required
0 { field(V,E,F): field(F) } 1 :- encoding(V,E).
0 { aggregate(V,E,A): aggregate_op(A) } 1 :- encoding(V,E).
0 { bin(V,E,B): binning(B) } 1 :- encoding(V,E).
0 { zero(V,E) } 1 :- encoding(V,E).
0 { log(V,E) } 1 :- encoding(V,E).

% pick one mark type

{ mark(V,M) : marktype(M) } = 1 :- visualization(V).

% stacking

0 { stack(V,S): stacking(S) } 1 :- visualization(V).

:- field(V,E1,F1), field(V,E2,F2), E1 > E2, F1 <= F2.
% :- channel(V,E1,C1), channel(V,E2,C2), E1 > E2, C1 <= C2.
