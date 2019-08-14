% @constraint Prefer to use only x over only y.
soft(chart,only_x_over_only_y,V,true) :- channel(V,_,y), not channel(V,_,x).

% @constraint Prefer not to have binned one dimensional chart.
soft(chart,binned_one_dimensional,V,true) :- #count { E: encoding(V,E) } = 1, bin(V,_,true).

% @constraint Prefer to orient vertically over horizontall. Chart orientation for bar and tick (with and without bin). Binned fields have short labels if they are quantitative while otherwise labels can be long.
soft(chart,orientation_horizontal_binned,V,true) :- bin(V,E,true), type(V,E,quantitative), not channel(V,E,x).

% @constraint Prefer 1D raw continuous tick for over 1D point (or any other).
soft(chart,one_dim_raw_continuous_tick_over_rest,V,true) :- #count { E: encoding(V,E) } = 1, encoding_fact(continuous,V,_), encoding_fact(raw,V,_), not mark(V,tick).
