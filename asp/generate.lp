% ====== Generators ======

% encodings

% maximum number for each multi channel encoding
#const max_extra_encs = 5.

obj_id(1..max_extra_encs).

{ encoding(E): obj_id(E) }.

:- not encoding(ID1), encoding(ID2), obj_id(ID1), obj_id(ID2), ID1 < ID2.

% properties of encodings

% channel and type have to be present
{ channel(E,C): channel(C) } = 1 :- encoding(E).
{ type(E,T): type(T) } = 1 :- encoding(E).

% other properties that are not required
0 { field(E,F): field(F) } 1 :- encoding(E).
0 { aggregate(E,A): aggregate_op(A) } 1 :- encoding(E).
0 { bin(E,B): binning(B) } 1 :- encoding(E).
0 { zero(E) } 1 :- encoding(E).
0 { log(E) } 1 :- encoding(E).

% pick one mark type

{ mark(M) : marktype(M) } = 1.

% maybe assign a task

0 { task(T): tasks(T) } 1.

% stacking

0 { stack(S): stacking(S) } 1.
