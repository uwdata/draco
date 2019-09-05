% @fact binned can be defined by a boolean or by a numeric binsize
encoding_fact(binned,V,E) :- bin(V,E,true).

% @fact discrete encoding
encoding_fact(discrete,V,E) :- type(V,E,(nominal;ordinal;temporal)).
encoding_fact(discrete,V,E) :- bin(V,E,true).

% @fact continuous encoding
encoding_fact(continuous,V,E) :- encoding(V,E), not encoding_fact(discrete,V,E).

% @fact raw encoding
encoding_fact(raw,V,E) :- encoding(V,E), not aggregate(V,E,_), bin(V,E,false).
encoding_fact(raw,V,E) :- encoding(V,E), not aggregate(V,E,_), not bin(V,E,_).

% @fact ordered encoding
encoding_fact(ordered,V,E) :- type(V,E,(ordinal;quantitative;temporal)).

encoding_fact(extent,V,(E,MIN,MAX)) :- field(V,E,F), extent(F,MIN,MAX).

encoding_fact(stacked,V,E) :- channel(V,E,(x;y)), channel(V,ED,(x;y)), encoding_fact(continuous,V,E), encoding_fact(discrete,V,ED), stack(V,S).
