% @constraint Prefer to use fewer encodings in general.
soft(encoding,encoding,V,E) :- encoding(V,E).

% @constraint Prefer to use fewer encodings with fields (count does not have a field).
soft(encoding,encoding_field,V,E) :- field(V,E,_).

% @constraint Prefer to use raw (no aggregate).
soft(encoding,aggregate,V,E) :- aggregate(V,E,_).

% @constraint Prefer to not bin.
soft(encoding,bin,V,E) :- bin(V,E,true).

% @constraint Prefer not to use the same field twice.
soft(encoding,same_field_2,V,F) :- view(V), field(F), { field(V,_,F) } = 2.

% @constraint Prefer not to use the same field three or more times.
soft(encoding,same_field_gte3,V,F) :- view(V), field(F), { field(V,_,F) } >= 3.

% @constraint Prefer not to use count more than once.
soft(encoding,count_twice,V,true) :- view(V), { aggregate(V,_,count) } >= 2.

% @constraint Prefer quantitative for bin.
soft(encoding,quant_bin,V,E) :- bin(V,E,true), not type(V,E,quantitative).

% @constraint Prefer not to use non-positional channels until all positional channels are used.
soft(encoding,non_positional_pref,V,true) :- channel(V,_,C), channel_definition(non_positional,C), not channel(V,_,(x;y)).

% @constraint Prefer not to use multiple non-positional encoding channels.
soft(encoding,multiple_non_pos,V,true) :- view(V), { channel(V,_,C): channel_definition(non_positional,C) } > 1.

% @constraint Aggregate plots should not use raw continuous as group by.
soft(encoding,aggregate_group_by_raw_non_temporal,V,E) :- aggregate(V,_,_), encoding_fact(continuous,V,E), not aggregate(V,E,_), not type(V,E,temporal).

% @constraint Aggregate should also have a discrete encoding to group by.
soft(encoding,agg_dim,V,true) :- aggregate(V,_,_), not encoding_fact(discrete,V,_).

% @constraint Prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion.
soft(encoding,x_y_raw,V,E) :- channel(V,EX,x), encoding_fact(discrete,V,EX), channel(V,EY,y), encoding_fact(discrete,V,EY), encoding(V,E), not aggregate(V,E,_), encoding_fact(continuous,V,E).

% @constraint Normalize between groupbys as stack op.
soft(encoding,stack_normalize,V,true) :- stack(V,normalize).

% @constraint Prefer quantitative > ordinal > nominal.
soft(encoding,type_quantitative,V,E) :- type(V,E,quantitative).

% @constraint Prefer quantitative > ordinal > nominal.
soft(encoding,type_ordinal,V,E) :- type(V,E,ordinal).

% @constraint Prefer quantitative > ordinal > nominal.
soft(encoding,type_nominal,V,E) :- type(V,E,nominal).
