% @fact continuous channel
channel_fact(continuous,V,C) :- channel(V,E,C), encoding_fact(continuous,V,E).

% @fact discrete channel
channel_fact(discrete,V,C) :- channel(V,E,C), encoding_fact(discrete,V,E).

% @fact ordered channel
channel_fact(ordered,V,C) :- channel(V,E,C), encoding_fact(ordered,V,E).

% @fact nominal channel
channel_fact(nominal,V,C) :- channel(V,E,C), type(V,E,nominal).

% @fact temporal channel
channel_fact(temporal,V,C) :- channel(V,E,C), type(V,E,temporal).
