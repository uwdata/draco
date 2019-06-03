% @constraint Prefer to use line chart for c_d temporal.
soft(chart,c_d_temporal_agg_not_line,V,true) :- chart_fact(continuous_discrete,V), not mark(V,line), encoding_fact(discrete,V,E), type(V,E,temporal), encoding_fact(continuous,V,E), aggregate(V,E,_).
