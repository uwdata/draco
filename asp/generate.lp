% ====== Generators ======

% pick one mark type
{ mark(M) : marktype(M) } = 1.

% encodings

% maximum number for each multi channel encoding
#const max_extra_encs = 5.

obj_id(0..max_extra_encs).

{ encoding(E): obj_id(E) }.

encoding(Id-1) :- encoding(Id), obj_id(Id), Id > 0.

% properties of encodings

% channel and type have to be present
{ channel(E,C): channel(C) } = 1 :- encoding(E).
{ type(E,T): type(T) } = 1 :- encoding(E).
{ scale(E,S): scale(S) } = 1 :- encoding(E).

% other properties that are not required
0 { field(E,F): field(F) } 1 :- encoding(E).
0 { aggregate(E,A): aggregate(A) } 1 :- encoding(E).
0 { bin(E,B): bin(B) } 1 :- encoding(E).
0 { zero(E) } 1 :- encoding(E).
