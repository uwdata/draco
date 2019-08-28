% encodings

% maximum number for each multi channel encoding
#const max_extra_encs = 3.

obj_id(1..max_extra_encs).

{ encoding(V,E): view(V), obj_id(E) }.

:- view(V), not encoding(V,ID), encoding(V,ID-1), obj_id(ID), obj_id(ID-1).

{ task(T): task_type(T) } = 1.

% properties of encodings

% channel and type have to be present
{ channel(V,E,C): channel_type(C) } = 1 :- encoding(V,E).
{ type(V,E,T): type_type(T) } = 1 :- encoding(V,E).

% other properties that are not required
{ field(V,E,F): fieldtype(F,_) } = 1 :- encoding(V,E).

% pick one mark type
{ mark(V,M): mark_type(M) } = 1 :- view(V).

:- type(V,E,nominal), field(V,E,(q1;q2)).
:- type(V,E,quantitative), field(V,E,n).
