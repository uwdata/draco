% @constraint Check mark.
type_check(invalid_mark,V) :- mark(V,M), not mark_type(M).

% @constraint Check channel
type_check(invalid_channel,V,E) :- channel(V,E,C), not channel_type(C).

% @constraint Check datatype
type_check(invalid_type,V,E) :- type(V,E,T), not type_type(T).

% @constraint Check aggregate op.
type_check(invalid_aggregate,V,E) :- aggregate(V,E,A), not aggregate_type(A).

% @constraint Check bin (boolean)
type_check(invalid_binbool,V,E) :- bin(V,E,B), not bin_type(B).
