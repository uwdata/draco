% properties of encodings

% channel and type have to be present
{ channel(V,E,C): channel_type(C) } = 1 :- encoding(V,E).
{ type(V,E,T): type_type(T) } = 1 :- encoding(V,E).

% other properties that are not required
0 { field(V,E,F): fieldtype(F,_) } 1 :- encoding(V,E).
0 { aggregate(V,E,A): aggregate_type(A) } 1 :- encoding(V,E).
0 { bin(V,E,B): bin_type(B) } 1 :- encoding(V,E).
0 { scale(V,E,S): scaletype_type(S) } 1 :- encoding(V,E).
0 { stack(V,S): stack_type(S) } 1 :- view(V).

% pick one mark type
{ mark(V,M): mark_type(M) } = 1 :- view(V).
