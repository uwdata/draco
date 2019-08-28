% @constraint Check mark.
type_check(invalid_mark,V) :- mark(V,M), not mark_type(M).

% @constraint Check channel
type_check(invalid_channel,V,E) :- channel(V,E,C), not channel_type(C).

% @constraint Check datatype
type_check(invalid_type,V,E) :- type(V,E,T), not type_type(T).

% @constraint Check scale
type_check(invalid_scale,V,E) :- scale(V,E,S), not scaletype_type(S).
