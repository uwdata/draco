% encodings

% maximum number for each multi channel encoding
#const max_extra_encs = 3.

obj_id(1..max_extra_encs).

{ encoding(V,E): view(V), obj_id(E) }.

:- view(V), not encoding(V,ID), encoding(V,ID-1), obj_id(ID), obj_id(ID-1).

% properties of encodings

% channel and type have to be present
{ channel(V,E,C): channel_type(C) } = 1 :- encoding(V,E).
{ type(V,E,T): type_type(T) } = 1 :- encoding(V,E).

% other properties that are not required
0 { field(V,E,F): fieldtype(F,_) } 1 :- encoding(V,E).
0 { aggregate(V,E,A): aggregate_type(A) } 1 :- encoding(V,E).
0 { bin(V,E,B): bin_type(B) } 1 :- encoding(V,E).

% pick one mark type
{ mark(V,M): mark_type(M) } = 1 :- view(V).
