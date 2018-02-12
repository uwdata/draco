% After adding a feature to this file, make sure to update `weights.lp` and run `process_features.py` as well.

% ====== Preferences ======

% prefer quantitative > ordinal > nominal

feature_term("type_q",E) :- type(E,quantitative).
feature_term("type_o",E) :- type(E,ordinal).
feature_term("type_n",E) :- type(E,nominal).

% prefer to use raw (no aggregate)
feature_term("aggregate",E) :- aggregate(E,_).

% prefer to not bin
feature_term("bin",E) :- bin(E,_).

% prefer binning with at most 12 buckets
feature_term("bin_high",E) :- bin(E,B), B > 12.

% prefer binning with more than 7 buckets
feature_term("bin_low",E) :- bin(E,B), B <= 7.

% prefer to use fewer encodings
feature_term("encoding",E) :- encoding(E).

% prefer to use fewer encodings with fields (count does not have a field)
feature_term("encoding_field",E) :- encoding(E), field(E,_).

% prefer not to use the same field multiple times
feature_term("same_field_2",F) :- field(F), { field(_,F) } = 2.
feature_term("same_field_3",F) :- field(F), { field(_,F) } = 3.
feature_term("same_field_4",F) :- field(F), { field(_,F) } = 4.
feature_term("same_field_gte5",F) :- field(F), { field(_,F) } >= 5.

% categorical color channel should not have too high cardinality
feature_term("categorical_cardinality",E) :- channel(E,color), type(E,nominal), cardinality(E,C), C > 20.

% shape channel should not have too high cardinality
feature_term("shape_cardinality",E) :- channel(E,shape), cardinality(E,C), C > 6.

% numbers should not be nominal
feature_term("number_nominal",E) :- type(E,nominal), field(E,F), fieldtype(F,number).

% bar and tick should not use size
feature_term("bar_size") :- mark(bar), channel(_,size).

feature_term("tick_size") :- mark(tick), channel(_,size).

% binned quantitative field should not have too low cardinality
feature_term("bin_cardinality",E) :- type(E,quantitative), bin(E,_), cardinality(E,C), C < 15.

% prefer quantitative for bin
feature_term("quant_bin",E) :- bin(E,_), not type(E,quantitative).

% aggregate should also have a discrete encoding to group by
feature_term("agg_dim") :- aggregate(_,_), not discrete(_).

% plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field
feature_term("only_discrete") :- not continuous(_).

% don't use bar, line, or area for raw data as it leads to occulusion
feature_term("bar_raw") :- mark(bar), not aggregate(_,_).

feature_term("line_raw") :- mark(line), not aggregate(_,_).

feature_term("area_raw") :- mark(area), not aggregate(_,_).

% prefer not to use multiple non-positional encoding channels
feature_term("multiple_non_pos") :- {channel(_,C): non_positional(C)} > 1.

% prefer not to use non-positional channels until all positional channels are used
feature_term("non_positional_pref") :- channel(_,C), non_positional(C), not channel(_,(x;y)).

% aggregate plots should not use raw continuous as group by
feature_term("aggregate_group_by_raw",E) :- aggregate(_,_), continuous(E), not aggregate(E,_).

% prefer not to use plot with x or y discrete and no aggregate as it leads to occlusion
feature_term("x_raw",E) :- channel(EX,x), discrete(EX), not aggregate(E,_), continuous(E).
feature_term("y_raw",E) :- channel(EY,y), discrete(EY), not aggregate(E,_), continuous(E).

% prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion
feature_term("x_y_raw",E) :- channel(EX,x), discrete(EX), channel(EY,y), discrete(EY), not aggregate(E,_), continuous(E).

% prefer not to use log scale
feature_term("log",E) :- log(E).

% prefer to include zero for continuous
feature_term("zero",E) :- continuous(E), not zero(E).

% prefer to use zero for the continuous channel of a bar chart
feature_term("zero_bar") :- mark(bar), continuous(E), channel(E,(x;y)), not zero(E).

% prefer zero for continuous size
feature_term("zero_size") :- continuous(E), channel(E,size), not zero(E).

% prefer not to use only row and column
feature_term("only_row_column") :- channel(_,(row;column)), not channel(_,x), not channel(_,y), not channel(_,color), not channel(_,size), not channel(_,opacity), not channel(_,shape).

% prefer not to use ordinal for fields with high cardinality
feature_term("high_cardinality_ordinal",E) :- type(E,ordinal), cardinality(E,C), C > 20.

% prefer to use only x instead of only y
feature_term("only_x") :- channel(_,y), not channel(_,x).

% Overplotting

% prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overlap
feature_term("position_entropy",E) :- channel(E,(x;y)), continuous(E), cardinality(E,C), C > 100, entropy(E,EN), EN <= 3, not aggregate(E,_).

% prefer not to use size when the cardinality is large on x or y
feature_term("high_cardinality_size",E) :- continuous(E), channel(_,size), cardinality(E,C), C > 100, channel(E,(x;y)).

% ====== Rankings ======

% continuous by continuous
is_c_c :- channel_continuous(x), channel_continuous(y).

feature_term("c_c_point") :- is_c_c, mark(point).
feature_term("c_c_bar") :- is_c_c, mark(bar).
feature_term("c_c_line") :- is_c_c, mark(line).
feature_term("c_c_area") :- is_c_c, mark(area).
feature_term("c_c_rule") :- is_c_c, mark(rule).
feature_term("c_c_text") :- is_c_c, mark(text).
feature_term("c_c_tick") :- is_c_c, mark(tick).
feature_term("c_c_rect") :- is_c_c, mark(rect).

% continuous by discrete (or continuous only)
is_c_d :- channel_continuous(x), not channel_continuous(y).
is_c_d :- channel_continuous(y), not channel_continuous(x).

% the continupus variable is a measure (it is aggregated) and there is no detail -> no overlap
no_overlap :- continuous(E), channel(E,(x;y)), aggregate(E,_), not channel(_,detail).

feature_term("c_d_point") :- is_c_d, not no_overlap, mark(point).
feature_term("c_d_bar") :- is_c_d, not no_overlap, mark(bar).
feature_term("c_d_line") :- is_c_d, not no_overlap, mark(line).
feature_term("c_d_area") :- is_c_d, not no_overlap, mark(area).
feature_term("c_d_rule") :- is_c_d, not no_overlap, mark(rule).
feature_term("c_d_text") :- is_c_d, not no_overlap, mark(text).
feature_term("c_d_tick") :- is_c_d, not no_overlap, mark(tick).
feature_term("c_d_rect") :- is_c_d, not no_overlap, mark(rect).

% no overlap

feature_term("c_d_no_overlap_point") :- is_c_d, no_overlap, mark(point).
feature_term("c_d_no_overlap_bar") :- is_c_d, no_overlap, mark(bar).
feature_term("c_d_no_overlap_line") :- is_c_d, no_overlap, mark(line).
feature_term("c_d_no_overlap_area") :- is_c_d, no_overlap, mark(area).
feature_term("c_d_no_overlap_rule") :- is_c_d, no_overlap, mark(rule).
feature_term("c_d_no_overlap_text") :- is_c_d, no_overlap, mark(text).
feature_term("c_d_no_overlap_tick") :- is_c_d, no_overlap, mark(tick).
feature_term("c_d_no_overlap_rect") :- is_c_d, no_overlap, mark(rect).


% discrete by discrete
is_d_d :- channel_discrete(x), channel_discrete(y).

feature_term("d_d_point") :- is_d_d, mark(point).
feature_term("d_d_bar") :- is_d_d, mark(bar).
feature_term("d_d_line") :- is_d_d, mark(line).
feature_term("d_d_area") :- is_d_d, mark(area).
feature_term("d_d_rule") :- is_d_d, mark(rule).
feature_term("d_d_text") :- is_d_d, mark(text).
feature_term("d_d_tick") :- is_d_d, mark(tick).
feature_term("d_d_rect") :- is_d_d, mark(rect).

% channel rankings à la APT

% TODO: add detail

feature_term("continuous_x",E) :- channel(E,x), continuous(E).
feature_term("continuous_y",E) :- channel(E,y), continuous(E).
feature_term("continuous_color",E) :- channel(E,color), continuous(E).
feature_term("continuous_opacity",E) :- channel(E,opacity), continuous(E).
feature_term("continuous_size",E) :- channel(E,size), continuous(E).
feature_term("continuous_shape",E) :- channel(E,shape), continuous(E).
feature_term("continuous_text",E) :- channel(E,text), continuous(E).
feature_term("continuous_row",E) :- channel(E,row), continuous(E).
feature_term("continuous_column",E) :- channel(E,column), continuous(E).

feature_term("ordered_x",E) :- channel(E,x), discrete(E), not type(E,nominal).
feature_term("ordered_y",E) :- channel(E,y), discrete(E), not type(E,nominal).
feature_term("ordered_color",E) :- channel(E,color), discrete(E), not type(E,nominal).
feature_term("ordered_opacity",E) :- channel(E,opacity), discrete(E), not type(E,nominal).
feature_term("ordered_size",E) :- channel(E,size), discrete(E), not type(E,nominal).
feature_term("ordered_shape",E) :- channel(E,shape), discrete(E), not type(E,nominal).
feature_term("ordered_text",E) :- channel(E,text), discrete(E), not type(E,nominal).
feature_term("ordered_row",E) :- channel(E,row), discrete(E), not type(E,nominal).
feature_term("ordered_column",E) :- channel(E,column), discrete(E), not type(E,nominal).

feature_term("nominal_x",E) :- channel(E,x), type(E,nominal).
feature_term("nominal_y",E) :- channel(E,y), type(E,nominal).
feature_term("nominal_color",E) :- channel(E,color), type(E,nominal).
feature_term("nominal_opacity",E) :- channel(E,opacity), type(E,nominal).
feature_term("nominal_size",E) :- channel(E,size), type(E,nominal).
feature_term("nominal_shape",E) :- channel(E,shape), type(E,nominal).
feature_term("nominal_text",E) :- channel(E,text), type(E,nominal).
feature_term("nominal_row",E) :- channel(E,row), type(E,nominal).
feature_term("nominal_column",E) :- channel(E,column), type(E,nominal).

feature_term("interesting_x",E) :- channel(E,x), field(E,F), interesting(F).
feature_term("interesting_y",E) :- channel(E,y), field(E,F), interesting(F).
feature_term("interesting_color",E) :- channel(E,color), field(E,F), interesting(F).
feature_term("interesting_opacity",E) :- channel(E,opacity), field(E,F), interesting(F).
feature_term("interesting_size",E) :- channel(E,size), field(E,F), interesting(F).
feature_term("interesting_shape",E) :- channel(E,shape), field(E,F), interesting(F).
feature_term("interesting_text",E) :- channel(E,text), field(E,F), interesting(F).
feature_term("interesting_row",E) :- channel(E,row), field(E,F), interesting(F).
feature_term("interesting_column",E) :- channel(E,column), field(E,F), interesting(F).

% aggregate weights

feature_term("aggregate_count",E) :- aggregate(E, count).
feature_term("aggregate_mean",E) :- aggregate(E, mean).
feature_term("aggregate_median",E) :- aggregate(E, median).
feature_term("aggregate_min",E) :- aggregate(E, min).
feature_term("aggregate_max",E) :- aggregate(E, max).
