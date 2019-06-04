% @constraint Prefer to use line chart for c_d temporal.
soft(chart,c_d_temporal_agg_not_line,V,true) :- chart_fact(continuous_discrete,V), not mark(V,line), encoding_fact(discrete,V,E), type(V,E,temporal), encoding_fact(continuous,V,E), aggregate(V,E,_).

% @constraint Prefer to use only x over only y.
soft(chart,only_x_over_only_y,V,true) :- channel(V,_,y), not channel(V,_,x).

% @constraint Prefer not to have binned one dimensional chart.
soft(chart,binned_one_dimensional,V,true) :- #count { E: encoding(V,E) } = 1, bin(V,_,true).

% @constraint Prefer to orient vertically over horizontall. Chart orientation for bar and tick (with and without bin). Binned fields have short labels if they are quantitative while otherwise labels can be long.
soft(chart,orientation_horizontal_binned,V,true) :- bin(V,E,_), type(V,E,quantitative), not channel(V,E,x).
