% @constraint Prefer not to use log scale.
soft(scale,log,V,E) :- scale(V,E,log).

% @constraint Prefer to include zero for continuous (binned doesn't need zero).
soft(scale,zero,V,E) :- encoding_fact(continuous,V,E), not scale(V,E,zero).

% @constraint Prefer to exclude zero for binned.
soft(scale,zero_bin,V,E) :- bin(V,E,true), scale(V,E,zero).

% @constraint Prefer zero size (even when binned).
soft(scale,zero_size,V,true) :- channel(V,E,size), not scale(V,E,zero).

% @constraint Prefer zero positional.
soft(scale,zero_positional,V,true) :- encoding_fact(continuous,V,E), channel(V,E,(x;y)), not scale(V,E,zero).

% @constraint Prefer not to use zero when the difference between min and max is larger than distance to 0.
soft(scale,zero_skew,V,true) :- scale(V,E,zero), field(V,E,F), data_fact(field,min_minus_max_gt_min_or_max_minus_zero,F).

% @constraint Do not include zero when the range of data includes zero.
soft(scale,includes_zero,V,E) :- scale(V,E,zero), field(V,E,F), data_fact(field,extent_includes_zero,F).
