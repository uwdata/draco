% After adding a feature to this file, make sure to update `weights.lp` and run `process_features.py` as well.

% ====== Preferences ======

% prefer quantitative > ordinal > nominal

feature_term(type_q,E) :- type(E,quantitative).
feature_term(type_o,E) :- type(E,ordinal).
feature_term(type_n,E) :- type(E,nominal).

% prefer to use raw (no aggregate)
feature_term(aggregate,E) :- aggregate(E,_).

% prefer to not bin
feature_term(bin,E) :- bin(E,_).

% prefer binning with at most 12 buckets
feature_term(bin_high,E) :- bin(E,B), B > 12.

% prefer binning with more than 7 buckets
feature_term(bin_low,E) :- bin(E,B), B <= 7.

% prefer to use fewer encodings
feature_term(encoding,E) :- encoding(E).

% prefer to use fewer encodings with fields (count does not have a field)
feature_term(encoding_field,E) :- encoding(E), field(E,_).

% prefer not to use the same field multiple times
feature_term(same_field_2,F) :- field(F), { field(_,F) } = 2.
feature_term(same_field_gte3,F) :- field(F), { field(_,F) } >= 3.

% prefer not to use count more than once
feature_term(count_twice) :- { aggregate(_,count) } = 2.

% categorical color channel should not have too high cardinality
feature_term(categorical_cardinality,E) :- channel(E,color), type(E,nominal), enc_cardinality(E,C), C > 20.

% shape channel should not have too high cardinality
feature_term(shape_cardinality,E) :- channel(E,shape), enc_cardinality(E,C), C > 6.

% numbers should not be nominal
feature_term(number_nominal,E) :- type(E,nominal), field(E,F), fieldtype(F,number).

% binned quantitative field should not have too low cardinality
feature_term(bin_cardinality,E) :- type(E,quantitative), bin(E,_), enc_cardinality(E,C), C < 15.

% prefer quantitative for bin
feature_term(quant_bin,E) :- bin(E,_), not type(E,quantitative).

% plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field
feature_term(only_discrete) :- not continuous(_).

% prefer not to use multiple non-positional encoding channels
feature_term(multiple_non_pos) :- {channel(_,C): non_positional(C)} > 1.

% prefer not to use non-positional channels until all positional channels are used
feature_term(non_positional_pref) :- channel(_,C), non_positional(C), not channel(_,(x;y)).

% aggregate plots should not use raw continuous as group by
feature_term(aggregate_group_by_raw,E) :- aggregate(_,_), continuous(E), not aggregate(E,_).

% aggregate should also have a discrete encoding to group by
feature_term(agg_dim) :- aggregate(_,_), not discrete(_).

% prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion
feature_term(x_y_raw,E) :- channel(EX,x), discrete(EX), channel(EY,y), discrete(EY), not aggregate(E,_), continuous(E).

% prefer not to use log scale
feature_term(log,E) :- log(E).

% prefer to include zero for continuous (binned doesn't need zero)
feature_term(zero,E) :- continuous(E), not zero(E).

% prefer zero size
feature_term(zero_size) :- continuous(E), channel(E,size), not zero(E).

% prefer zero positional
feature_term(zero_positional) :- continuous(E), channel(E,(x;y)), not zero(E).

% prefer not to use zero when the difference between min and max is larger than distance to 0
feature_term(zero_skew) :- enc_extent(E,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX, zero(E).

% do not include zero when the range of data includes zero
feature_term(includes_zero) :- zero(E), extent(E,MIN,MAX), MIN < 0, MAX > 0.

% prefer not to use only row and column
feature_term(only_row_column) :- channel(_,(row;column)), not channel(_,x), not channel(_,y), not channel(_,color), not channel(_,size), not channel(_,opacity), not channel(_,shape).

% prefer to use only x instead of only y
feature_term(only_x) :- channel(_,y), not channel(_,x).

% chart orientation for bar and tick (with and without bin)
% binned fields have short labels if they are quantitative while otherwise labels can be long
feature_term(orientation_binned) :- channel(E,y), bin(E,_), type(E,quantitative).
feature_term(orientation_discrete) :- channel(E,x), discrete(ordinal;nominal).

% prefer not to use ordinal for fields with high cardinality
feature_term(high_cardinality_ordinal,E) :- type(E,ordinal), enc_cardinality(E,C), C > 30.

% prefer not to use nominal for fields with high cardinality
feature_term(high_cardinality_nominal,E) :- type(E,nominal), enc_cardinality(E,C), C > 12.

% avoid high cardinality on x or column as it causes horizontal scrolling
feature_term(horizontal_scrolling,E) :- channel(E,x), discrete(E), enc_cardinality(E,C), C > 20.
feature_term(horizontal_scrolling,E) :- channel(E,columm), discrete(E), enc_cardinality(E,C), C > 5.

% prefer to use temporal type with dates
feature_term(temporal_date,E) :- field(E,F), fieldtype(F,date), not type(E,temporal).

% prefer quantitative for numbers with high cardinality
feature_term(quantitative_numbers) :- field(E,F), fieldtype(F,number), cardinality(F,C), C > 20, not bin(E,_), not type(E,quantitative).

% prefer not to use numbers as temporal
feature_term(number_dates) :- field(E,F), fieldtype(F,number), type(E,temporal).

% Overplotting

% prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overlap
feature_term(position_entropy,E) :- channel(E,(x;y)), continuous(E), enc_cardinality(E,C), C > 100, enc_entropy(E,EN), EN <= 12, not aggregate(E,_).

% prefer not to use size when the cardinality is large on x or y
feature_term(high_cardinality_size,E) :- continuous(E), channel(_,size), enc_cardinality(E,C), C > 100, channel(E,(x;y)).

% prefer to not use stacking when opacity is used
feature_term(stack_opacity) :- stack(_), channel(_,opacity).

% prefer not to aggregate for value tasks
feature_term(value_agg) :- task(value), aggregate(_,_).

% positional interactions
feature_term(x_row) :- channel(_,x), channel(_,row), enc_interesting(x).
feature_term(y_row) :- channel(_,y), channel(_,row), enc_interesting(y).
feature_term(x_column) :- channel(_,x), channel(_,column), enc_interesting(x).
feature_term(y_column) :- channel(_,y), channel(_,column), enc_interesting(y).

% prefer not to use continuous on x, discrete on y, and column
feature_term(c_d_column) :- channel_continuous(x), channel_discrete(y), channel(_,column).

% prefer time on x
feature_term(temporal_y) :- type(E,temporal), channel(E,x).

% ====== Rankings ======

% continuous by continuous
is_c_c :- channel_continuous(x), channel_continuous(y).

feature_term(c_c_point) :- is_c_c, mark(point).
feature_term(c_c_line) :- is_c_c, mark(line).
feature_term(c_c_area) :- is_c_c, mark(area).
feature_term(c_c_text) :- is_c_c, mark(text).
feature_term(c_c_tick) :- is_c_c, mark(tick).

% continuous by discrete (or continuous only)
is_c_d :- channel_continuous(x), not channel_continuous(y).
is_c_d :- channel_continuous(y), not channel_continuous(x).

% the continuous variable is a measure (it is aggregated) and all other channels are aggregated -> no overlap
non_pos_unaggregated :- channel(E,C), non_positional(C), not aggregate(E,_).
no_overlap :- is_c_d, continuous(E), channel(E,(x;y)), aggregate(E,_),not non_pos_unaggregated.
% data size is as small as discrete dimension -> no overlap
no_overlap :- is_c_d, data_size(S), channel(E,(x;y)), discrete(E), enc_cardinality(E,S).

feature_term(c_d_point) :- is_c_d, not no_overlap, mark(point).
feature_term(c_d_bar) :- is_c_d, not no_overlap, mark(bar).
feature_term(c_d_line) :- is_c_d, not no_overlap, mark(line).
feature_term(c_d_area) :- is_c_d, not no_overlap, mark(area).
feature_term(c_d_text) :- is_c_d, not no_overlap, mark(text).
feature_term(c_d_tick) :- is_c_d, not no_overlap, mark(tick).

% no overlap

feature_term(c_d_no_overlap_point) :- is_c_d, no_overlap, mark(point).
feature_term(c_d_no_overlap_bar) :- is_c_d, no_overlap, mark(bar).
feature_term(c_d_no_overlap_line) :- is_c_d, no_overlap, mark(line).
feature_term(c_d_no_overlap_area) :- is_c_d, no_overlap, mark(area).
feature_term(c_d_no_overlap_text) :- is_c_d, no_overlap, mark(text).
feature_term(c_d_no_overlap_tick) :- is_c_d, no_overlap, mark(tick).


% discrete by discrete
is_d_d :- channel_discrete(x), channel_discrete(y).

% no overlap if all other dimensions are aggregated
no_overlap :- is_d_d, not non_pos_unaggregated.

feature_term(d_d_point) :- is_d_d, mark(point).
feature_term(d_d_text) :- is_d_d, mark(text).
feature_term(d_d_rect) :- is_d_d, mark(rect).

feature_term(d_d_no_overlap_point) :- is_d_d, mark(point).
feature_term(d_d_no_overlap_text) :- is_d_d, mark(text).
feature_term(d_d_no_overlap_rect) :- is_d_d, mark(rect).

% channel rankings à la APT

feature_term(continuous_x,E) :- channel(E,x), continuous(E).
feature_term(continuous_y,E) :- channel(E,y), continuous(E).
feature_term(continuous_color,E) :- channel(E,color), continuous(E).
feature_term(continuous_opacity,E) :- channel(E,opacity), continuous(E).
feature_term(continuous_size,E) :- channel(E,size), continuous(E).
feature_term(continuous_text,E) :- channel(E,text), continuous(E).

feature_term(ordered_x,E) :- channel(E,x), discrete(E), not type(E,nominal).
feature_term(ordered_y,E) :- channel(E,y), discrete(E), not type(E,nominal).
feature_term(ordered_color,E) :- channel(E,color), discrete(E), not type(E,nominal).
feature_term(ordered_opacity,E) :- channel(E,opacity), discrete(E), not type(E,nominal).
feature_term(ordered_size,E) :- channel(E,size), discrete(E), not type(E,nominal).
feature_term(ordered_text,E) :- channel(E,text), discrete(E), not type(E,nominal).
feature_term(ordered_row,E) :- channel(E,row), discrete(E), not type(E,nominal).
feature_term(ordered_column,E) :- channel(E,column), discrete(E), not type(E,nominal).

feature_term(nominal_x,E) :- channel(E,x), type(E,nominal).
feature_term(nominal_y,E) :- channel(E,y), type(E,nominal).
feature_term(nominal_color,E) :- channel(E,color), type(E,nominal).
feature_term(nominal_shape,E) :- channel(E,shape), type(E,nominal).
feature_term(nominal_text,E) :- channel(E,text), type(E,nominal).
feature_term(nominal_row,E) :- channel(E,row), type(E,nominal).
feature_term(nominal_column,E) :- channel(E,column), type(E,nominal).
feature_term(nominal_detail,E) :- channel(E,detail), type(E,nominal).

feature_term(interesting_x,E) :- channel(E,x), enc_interesting(E).
feature_term(interesting_y,E) :- channel(E,y), enc_interesting(E).
feature_term(interesting_color,E) :- channel(E,color), enc_interesting(E).
feature_term(interesting_opacity,E) :- channel(E,opacity), enc_interesting(E).
feature_term(interesting_size,E) :- channel(E,size), enc_interesting(E).
feature_term(interesting_shape,E) :- channel(E,shape), enc_interesting(E).
feature_term(interesting_text,E) :- channel(E,text), enc_interesting(E).
feature_term(interesting_row,E) :- channel(E,row), enc_interesting(E).
feature_term(interesting_column,E) :- channel(E,column), enc_interesting(E).
feature_term(interesting_detail,E) :- channel(E,detail), enc_interesting(E).

% aggregations

feature_term(aggregate_count,E) :- aggregate(E,count).
feature_term(aggregate_sum,E) :- aggregate(E,sum).
feature_term(aggregate_mean,E) :- aggregate(E,mean).
feature_term(aggregate_median,E) :- aggregate(E,median).
feature_term(aggregate_min,E) :- aggregate(E,min).
feature_term(aggregate_max,E) :- aggregate(E,max).
feature_term(aggregate_stdev,E) :- aggregate(E,stdev).

% task - marktype correlations

feature_term(value_point) :- task(value), mark(point).
feature_term(value_bar) :- task(value), mark(bar).
feature_term(value_line) :- task(value), mark(line).
feature_term(value_area) :- task(value), mark(area).
feature_term(value_text) :- task(value), mark(text).
feature_term(value_tick) :- task(value), mark(tick).
feature_term(value_rect) :- task(value), mark(rect).

feature_term(summary_point) :- task(summary), mark(point).
feature_term(summary_bar) :- task(summary), mark(bar).
feature_term(summary_line) :- task(summary), mark(line).
feature_term(summary_area) :- task(summary), mark(area).
feature_term(summary_text) :- task(summary), mark(text).
feature_term(summary_tick) :- task(summary), mark(tick).
feature_term(summary_rect) :- task(summary), mark(rect).

feature_term(value_channel_x,E) :- task(value), channel(E,x), enc_interesting(E).
feature_term(value_channel_y,E) :- task(value), channel(E,y), enc_interesting(E).
feature_term(value_channel_color,E) :- task(value), channel(E,color), enc_interesting(E).
feature_term(value_channel_opacity,E) :- task(value), channel(E,opacity), enc_interesting(E).
feature_term(value_channel_size,E) :- task(value), channel(E,size), enc_interesting(E).
feature_term(value_channel_shape,E) :- task(value), channel(E,shape), enc_interesting(E).
feature_term(value_channel_text,E) :- task(value), channel(E,text), enc_interesting(E).
feature_term(value_channel_row,E) :- task(value), channel(E,row), enc_interesting(E).
feature_term(value_channel_column,E) :- task(value), channel(E,column), enc_interesting(E).
feature_term(value_channel_detail,E) :- task(value), channel(E,detail), enc_interesting(E).

feature_term(summary_channel_x,E) :- task(summary), channel(E,x), enc_interesting(E).
feature_term(summary_channel_y,E) :- task(summary), channel(E,y), enc_interesting(E).
feature_term(summary_channel_color,E) :- task(summary), channel(E,color), enc_interesting(E).
feature_term(summary_channel_opacity,E) :- task(summary), channel(E,opacity), enc_interesting(E).
feature_term(summary_channel_size,E) :- task(summary), channel(E,size), enc_interesting(E).
feature_term(summary_channel_shape,E) :- task(summary), channel(E,shape), enc_interesting(E).
feature_term(summary_channel_text,E) :- task(summary), channel(E,text), enc_interesting(E).
feature_term(summary_channel_row,E) :- task(summary), channel(E,row), enc_interesting(E).
feature_term(summary_channel_column,E) :- task(summary), channel(E,column), enc_interesting(E).
feature_term(summary_channel_detail,E) :- task(summary), channel(E,detail), enc_interesting(E).

% stack

feature_term(stack_zero) :- stack(zero).
feature_term(stack_normalize) :- stack(normalize).
