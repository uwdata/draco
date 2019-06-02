% view
view(V) :- view(V).

% @primitive mark
mark(V,M) :- mark(V,M).

% @primitive encoding
encoding(V,E) :- encoding(V,E).

% @primitive channel
channel(V,E,C) :- channel(V,E,C).

% @primivite field
field(V,E,F) :- field(V,E,F).

% @primitive type
type(V,E,T) :- type(V,E,T).

% @primitive scale
scale(V,E,S) :- scale(V,E,S).

% @primitive bin (boolean)
bin(V,E,B) :- bin(V,E,B).

% @primitive aggregate
aggregate(V,E,A) :- aggregate(V,E,A).

spec(mark,V,M) :- mark(V,M).
spec(encoding,V,E) :- encoding(V,E).
spec(channel,V,(E,C)) :- channel(V,E,C).
spec(field,V,(E,F)) :- field(V,E,F).
spec(type,V,(E,T)) :- type(V,E,T).
spec(scale,V,(E,S)) :- scale(V,E,S).
spec(bin,V,(E,B)) :- scale(V,E,B).
spec(aggregate,V,(E,A)) :- aggregate(V,E,A).
