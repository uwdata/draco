% @fact continuous by continuous
chart_fact(continuous_continuous,V) :- channel_fact(continuous,V,x), channel_fact(continuous,V,y).

% fact continuous by discrete
chart_fact(continuous_discrete,V) :- channel_fact(continuous,V,x), channel_fact(discrete,V,y).
chart_fact(continuous_discrete,V) :- channel_fact(continuous,V,y), channel_fact(discrete,V,x).

% fact discrete by discrete
chart_fact(discrete_discrete,V) :- channel_fact(discrete,V,x), channel_fact(discrete,V,y).

% @fact The continuous variable is a measure (it is aggregated) and all other channels are aggregated, or we use stack -> no overlap.
chart_fact(non_position_unaggregated,V) :- channel(V,E,C), channel_definition(non_positional,C).

% @fact overlap
chart_fact(overlap_x_y,V) :- data_fact(overlap,definitely,(F1,F2)), field(V,E1,F1), field(V,E2,F2), channel(V,E1,(x;y)), channel(V,E2,(x;y)).
chart_fact(no_overlap_x_y,V) :-  data_fact(overlap,definitely_not,(F1,F2)), field(V,E1,F1), field(V,E2,F2), channel(V,E1,(x;y)), channel(V,E2,(x;y)).

% @fact overlap
chart_fact(no_overlap,V) :- chart_fact(continuous_discrete,V), encoding_fact(continuous,V,E), channel(V,E,(x;y)), aggregate(V,E,_), not chart_fact(non_position_unaggregated,V).
chart_fact(no_overlap,V) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap_x_y,V).

chart_fact(overlap,V) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), chart_fact(overlap_x_y,V).
chart_fact(overlap,V) :- chart_fact(discrete_discrete,V), channel(V,E,C), not channel(V,_,(row;column)), not chart_fact(no_overlap,V), chart_fact(overlap_x_y,V).

% @fact orientation
chart_fact(orientation_vertical,V) :- mark(V,(bar;tick;area;line)), channel_fact(discrete,V,x).
chart_fact(orientation_vertical,V) :- mark(V,(area;line)), channel_fact(continuous,V,x), channel_fact(continuous,V,y).
chart_fact(orientation_horizontal,V) :- mark(V,(bar;tick;area;line)), channel_fact(discrete,V,y).
