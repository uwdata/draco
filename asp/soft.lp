% After adding a soft constraint to this file, make sure to update `weights.lp` and run `process_softs.py`..

% ====== Preferences ======

% Prefer to use raw (no aggregate).
soft(aggregate,E) :- aggregate(E,_).

% Prefer to not bin.
soft(bin,E) :- bin(E,_).

% Prefer binning with at most 12 buckets.
soft(bin_high,E) :- bin(E,B), B > 12.

% Prefer binning with more than 7 buckets.
soft(bin_low,E) :- bin(E,B), B <= 7.

% Prefer to use fewer encodings.
soft(encoding,E) :- encoding(E).

% Prefer to use fewer encodings with fields (count does not have a field).
soft(encoding_field,E) :- encoding(E), field(E,_).

% Prefer not to use the same field multiple times.
soft(same_field_2,F) :- field(F), { field(_,F) } = 2.
soft(same_field_gte3,F) :- field(F), { field(_,F) } >= 3.

% Prefer not to use count more than once.
soft(count_twice) :- { aggregate(_,count) } = 2.

% Shape channel should not have too high cardinality.
soft(shape_cardinality,E) :- channel(E,shape), discrete_cardinality(E,C), C > 5.

% Numbers should not be nominal.
soft(number_nominal,E) :- type(E,nominal), field(E,F), fieldtype(F,number).

% Binned quantitative field should not have too low cardinality.
soft(bin_cardinality,E) :- type(E,quantitative), bin(E,_), enc_cardinality(E,C), C < 15.

% Prefer quantitative for bin.
soft(quant_bin,E) :- bin(E,_), not type(E,quantitative).

% Plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field.
soft(only_discrete) :- not continuous(_).

% Prefer not to use multiple non-positional encoding channels.
soft(multiple_non_pos) :- {channel(_,C): non_positional(C)} > 1.

% Prefer not to use non-positional channels until all positional channels are used.
soft(non_positional_pref) :- channel(_,C), non_positional(C), not channel(_,(x;y)).

% Aggregate plots should not use raw continuous as group by.
soft(aggregate_group_by_raw,E) :- aggregate(_,_), continuous(E), not aggregate(E,_).

% Aggregate should also have a discrete encoding to group by.
soft(agg_dim) :- aggregate(_,_), not discrete(_).

% Prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion.
soft(x_y_raw,E) :- channel(EX,x), discrete(EX), channel(EY,y), discrete(EY), not aggregate(E,_), continuous(E).

% Prefer not to use log scale.
soft(log,E) :- log(E).

% Prefer to include zero for continuous (binned doesn't need zero).
soft(zero,E) :- continuous(E), not zero(E).

% Prefer zero size (even when binned).
soft(zero_size) :- channel(E,size), not zero(E).

% Prefer zero positional.
soft(zero_positional) :- continuous(E), channel(E,(x;y)), not zero(E).

% Prefer not to use zero when the difference between min and max is larger than distance to 0.
soft(zero_skew) :- enc_extent(E,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX, zero(E).

% Do not include zero when the range of data includes zero.
soft(includes_zero) :- zero(E), extent(E,MIN,MAX), MIN < 0, MAX > 0.

% Prefer to use only x instead of only y.
soft(only_x) :- channel(_,y), not channel(_,x).

% Chart orientation for bar and tick (with and without bin).
% Binned fields have short labels if they are quantitative while otherwise labels can be long.
soft(orientation_binned) :- bin(E,_), type(E,quantitative), not channel(E,x).

% Prefer not to use ordinal for fields with high cardinality.
soft(high_cardinality_ordinal,E) :- type(E,ordinal), discrete_cardinality(E,C), C > 30.

% Prefer not to use nominal for fields with high cardinality.
soft(high_cardinality_nominal,E) :- type(E,nominal), enc_cardinality(E,C), C > 12.

% Prefer not to use high cardinality nominal for color.
soft(high_cardinality_nominal_color,E) :- type(E,nominal), channel(E,color), enc_cardinality(E,C), C > 10.

% Avoid high cardinality on x or column as it causes horizontal scrolling.
soft(horizontal_scrolling,E) :- channel(E,x), discrete_cardinality(E,C), C > 50.
soft(horizontal_scrolling,E) :- channel(E,columm), discrete_cardinality(E,C), C > 5.

% Prefer to use temporal type with dates.
soft(temporal_date,E) :- field(E,F), fieldtype(F,datetime), not type(E,temporal).

% Prefer quantitative for numbers with high cardinality.
soft(quantitative_numbers) :- field(E,F), fieldtype(F,number), cardinality(F,C), C > 20, not bin(E,_), not type(E,quantitative).

% Overplotting.

% Prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overplot.
soft(position_entropy,E) :- channel(E,(x;y)), continuous(E), enc_cardinality(E,C), C > 100, enc_entropy(E,EN), EN <= 12, not aggregate(E,_).

% Prefer not to use size when the cardinality is large on x or y.
soft(high_cardinality_size,E) :- continuous(E), channel(_,size), enc_cardinality(E,C), C > 100, channel(E,(x;y)).

% Prefer not to aggregate for value tasks.
soft(value_agg) :- task(value), aggregate(_,_).

% Prefer not to use row and column for summary tasks as it makes it difficult to compare.
soft(facet_summary,E) :- task(summary), channel(E,row).

% Positional interactions as suggested by Kim et al.
soft(x_row) :- channel(_,x), channel(_,row).
soft(y_row) :- channel(_,y), channel(_,row).
soft(x_column) :- channel(_,x), channel(_,column).
soft(y_column) :- channel(_,y), channel(_,column).

% Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_high, E) :- channel(E,color), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).
soft(color_entropy_low, E) :- channel(E,color), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).
soft(size_entropy_high, E) :- channel(E,size), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).
soft(size_entropy_low, E) :- channel(E,size), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).

% Prefer not to use continuous on x, discrete on y, and column.
soft(c_d_column) :- channel_continuous(x), channel_discrete(y), channel(_,column).

% Prefer time on x.
soft(temporal_y) :- type(E,temporal), not channel(E,x).

% Prefer not to overlap with DxD.
soft(d_d_overlap) :- is_d_d, overlap.

% ====== Rankings ======

% === Data Types ===

% Prefer quantitative > ordinal > nominal.
soft(type_q,E) :- type(E,quantitative).
soft(type_o,E) :- type(E,ordinal).
soft(type_n,E) :- type(E,nominal).


% === Mark types ===

soft(c_c_point) :- is_c_c, mark(point).
soft(c_c_line) :- is_c_c, mark(line).
soft(c_c_area) :- is_c_c, mark(area).
soft(c_c_text) :- is_c_c, mark(text).
soft(c_c_tick) :- is_c_c, mark(tick).


soft(c_d_point) :- is_c_d, not no_overlap, mark(point).
soft(c_d_bar) :- is_c_d, not no_overlap, mark(bar).
soft(c_d_line) :- is_c_d, not no_overlap, mark(line).
soft(c_d_area) :- is_c_d, not no_overlap, mark(area).
soft(c_d_text) :- is_c_d, not no_overlap, mark(text).
soft(c_d_tick) :- is_c_d, not no_overlap, mark(tick).

soft(c_d_no_overlap_point) :- is_c_d, no_overlap, mark(point).
soft(c_d_no_overlap_bar) :- is_c_d, no_overlap, mark(bar).
soft(c_d_no_overlap_line) :- is_c_d, no_overlap, mark(line).
soft(c_d_no_overlap_area) :- is_c_d, no_overlap, mark(area).
soft(c_d_no_overlap_text) :- is_c_d, no_overlap, mark(text).
soft(c_d_no_overlap_tick) :- is_c_d, no_overlap, mark(tick).


soft(d_d_point) :- is_d_d, mark(point).
soft(d_d_text) :- is_d_d, mark(text).
soft(d_d_rect) :- is_d_d, mark(rect).


% === Channel rankings à la APT ===

soft(continuous_x,E) :- channel(E,x), continuous(E).
soft(continuous_y,E) :- channel(E,y), continuous(E).
soft(continuous_color,E) :- channel(E,color), continuous(E).
soft(continuous_size,E) :- channel(E,size), continuous(E).
soft(continuous_text,E) :- channel(E,text), continuous(E).

soft(ordered_x,E) :- channel(E,x), discrete(E), not type(E,nominal).
soft(ordered_y,E) :- channel(E,y), discrete(E), not type(E,nominal).
soft(ordered_color,E) :- channel(E,color), discrete(E), not type(E,nominal).
soft(ordered_size,E) :- channel(E,size), discrete(E), not type(E,nominal).
soft(ordered_text,E) :- channel(E,text), discrete(E), not type(E,nominal).
soft(ordered_row,E) :- channel(E,row), discrete(E), not type(E,nominal).
soft(ordered_column,E) :- channel(E,column), discrete(E), not type(E,nominal).

soft(nominal_x,E) :- channel(E,x), type(E,nominal).
soft(nominal_y,E) :- channel(E,y), type(E,nominal).
soft(nominal_color,E) :- channel(E,color), type(E,nominal).
soft(nominal_shape,E) :- channel(E,shape), type(E,nominal).
soft(nominal_text,E) :- channel(E,text), type(E,nominal).
soft(nominal_row,E) :- channel(E,row), type(E,nominal).
soft(nominal_column,E) :- channel(E,column), type(E,nominal).
soft(nominal_detail,E) :- channel(E,detail), type(E,nominal).

soft(interesting_x,E) :- channel(E,x), enc_interesting(E).
soft(interesting_y,E) :- channel(E,y), enc_interesting(E).
soft(interesting_color,E) :- channel(E,color), enc_interesting(E).
soft(interesting_size,E) :- channel(E,size), enc_interesting(E).
soft(interesting_shape,E) :- channel(E,shape), enc_interesting(E).
soft(interesting_text,E) :- channel(E,text), enc_interesting(E).
soft(interesting_row,E) :- channel(E,row), enc_interesting(E).
soft(interesting_column,E) :- channel(E,column), enc_interesting(E).
soft(interesting_detail,E) :- channel(E,detail), enc_interesting(E).

% === Aggregations ===

soft(aggregate_count,E) :- aggregate(E,count).
soft(aggregate_sum,E) :- aggregate(E,sum).
soft(aggregate_mean,E) :- aggregate(E,mean).
soft(aggregate_median,E) :- aggregate(E,median).
soft(aggregate_min,E) :- aggregate(E,min).
soft(aggregate_max,E) :- aggregate(E,max).
soft(aggregate_stdev,E) :- aggregate(E,stdev).


% === Stack ===

soft(stack_zero) :- stack(zero).
soft(stack_normalize) :- stack(normalize).


% === Task - marktype correlations ===

soft(value_point) :- task(value), mark(point).
soft(value_bar) :- task(value), mark(bar).
soft(value_line) :- task(value), mark(line).
soft(value_area) :- task(value), mark(area).
soft(value_text) :- task(value), mark(text).
soft(value_tick) :- task(value), mark(tick).
soft(value_rect) :- task(value), mark(rect).

soft(summary_point) :- task(summary), mark(point).
soft(summary_bar) :- task(summary), mark(bar).
soft(summary_line) :- task(summary), mark(line).
soft(summary_area) :- task(summary), mark(area).
soft(summary_text) :- task(summary), mark(text).
soft(summary_tick) :- task(summary), mark(tick).
soft(summary_rect) :- task(summary), mark(rect).


% === Task - channel correlations ===

soft(value_continuous_x,E) :- task(value), channel(E,x), continuous(E), enc_interesting(E).
soft(value_continuous_y,E) :- task(value), channel(E,y), continuous(E), enc_interesting(E).
soft(value_continuous_color,E) :- task(value), channel(E,color), continuous(E), enc_interesting(E).
soft(value_continuous_size,E) :- task(value), channel(E,size), continuous(E), enc_interesting(E).
soft(value_continuous_text,E) :- task(value), channel(E,text), continuous(E), enc_interesting(E).

soft(value_discrete_x,E) :- task(value), channel(E,x), discrete(E), enc_interesting(E).
soft(value_discrete_y,E) :- task(value), channel(E,y), discrete(E), enc_interesting(E).
soft(value_discrete_color,E) :- task(value), channel(E,color), discrete(E), enc_interesting(E).
soft(value_discrete_shape,E) :- task(value), channel(E,shape), discrete(E), enc_interesting(E).
soft(value_discrete_size,E) :- task(value), channel(E,size), discrete(E), enc_interesting(E).
soft(value_discrete_text,E) :- task(value), channel(E,text), discrete(E), enc_interesting(E).
soft(value_discrete_row,E) :- task(value), channel(E,row), discrete(E), enc_interesting(E).
soft(value_discrete_column,E) :- task(value), channel(E,column), discrete(E), enc_interesting(E).

soft(summary_continuous_x,E) :- task(summary), channel(E,x), continuous(E), enc_interesting(E).
soft(summary_continuous_y,E) :- task(summary), channel(E,y), continuous(E), enc_interesting(E).
soft(summary_continuous_color,E) :- task(summary), channel(E,color), continuous(E), enc_interesting(E).
soft(summary_continuous_size,E) :- task(summary), channel(E,size), continuous(E), enc_interesting(E).
soft(summary_continuous_text,E) :- task(summary), channel(E,text), continuous(E), enc_interesting(E).

soft(summary_discrete_x,E) :- task(summary), channel(E,x), discrete(E), enc_interesting(E).
soft(summary_discrete_y,E) :- task(summary), channel(E,y), discrete(E), enc_interesting(E).
soft(summary_discrete_color,E) :- task(summary), channel(E,color), discrete(E), enc_interesting(E).
soft(summary_discrete_shape,E) :- task(summary), channel(E,shape), discrete(E), enc_interesting(E).
soft(summary_discrete_size,E) :- task(summary), channel(E,size), discrete(E), enc_interesting(E).
soft(summary_discrete_text,E) :- task(summary), channel(E,text), discrete(E), enc_interesting(E).
soft(summary_discrete_row,E) :- task(summary), channel(E,row), discrete(E), enc_interesting(E).
soft(summary_discrete_column,E) :- task(summary), channel(E,column), discrete(E), enc_interesting(E).
