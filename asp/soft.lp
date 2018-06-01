% After adding a soft constraint to this file, make sure to update `weights.lp` and run `process_violations.py`..

% ====== Preferences ======

% Prefer to use raw (no aggregate).
violation(aggregate,E) :- aggregate(E,_).

% Prefer to not bin.
violation(bin,E) :- bin(E,_).

% Prefer binning with at most 12 buckets.
violation(bin_high,E) :- bin(E,B), B > 12.

% Prefer binning with more than 7 buckets.
violation(bin_low,E) :- bin(E,B), B <= 7.

% Prefer to use fewer encodings.
violation(encoding,E) :- encoding(E).

% Prefer to use fewer encodings with fields (count does not have a field).
violation(encoding_field,E) :- encoding(E), field(E,_).

% Prefer not to use the same field multiple times.
violation(same_field_2,F) :- field(F), { field(_,F) } = 2.
violation(same_field_gte3,F) :- field(F), { field(_,F) } >= 3.

% Prefer not to use count more than once.
violation(count_twice) :- { aggregate(_,count) } = 2.

% Shape channel should not have too high cardinality.
violation(shape_cardinality,E) :- channel(E,shape), discrete_cardinality(E,C), C > 5.

% Numbers should not be nominal.
violation(number_nominal,E) :- type(E,nominal), field(E,F), fieldtype(F,number).

% Binned quantitative field should not have too low cardinality.
violation(bin_cardinality,E) :- type(E,quantitative), bin(E,_), enc_cardinality(E,C), C < 15.

% Prefer quantitative for bin.
violation(quant_bin,E) :- bin(E,_), not type(E,quantitative).

% Plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field.
violation(only_discrete) :- not continuous(_).

% Prefer not to use multiple non-positional encoding channels.
violation(multiple_non_pos) :- {channel(_,C): non_positional(C)} > 1.

% Prefer not to use non-positional channels until all positional channels are used.
violation(non_positional_pref) :- channel(_,C), non_positional(C), not channel(_,(x;y)).

% Aggregate plots should not use raw continuous as group by.
violation(aggregate_group_by_raw,E) :- aggregate(_,_), continuous(E), not aggregate(E,_).

% Aggregate should also have a discrete encoding to group by.
violation(agg_dim) :- aggregate(_,_), not discrete(_).

% Prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion.
violation(x_y_raw,E) :- channel(EX,x), discrete(EX), channel(EY,y), discrete(EY), not aggregate(E,_), continuous(E).

% Prefer not to use log scale.
violation(log,E) :- log(E).

% Prefer to include zero for continuous (binned doesn't need zero).
violation(zero,E) :- continuous(E), not zero(E).

% Prefer zero size (even when binned).
violation(zero_size) :- channel(E,size), not zero(E).

% Prefer zero positional.
violation(zero_positional) :- continuous(E), channel(E,(x;y)), not zero(E).

% Prefer not to use zero when the difference between min and max is larger than distance to 0.
violation(zero_skew) :- enc_extent(E,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX, zero(E).

% Do not include zero when the range of data includes zero.
violation(includes_zero) :- zero(E), extent(E,MIN,MAX), MIN < 0, MAX > 0.

% Prefer to use only x instead of only y.
violation(only_x) :- channel(_,y), not channel(_,x).

% Chart orientation for bar and tick (with and without bin).
% Binned fields have short labels if they are quantitative while otherwise labels can be long.
violation(orientation_binned) :- bin(E,_), type(E,quantitative), not channel(E,x).

% Prefer not to use ordinal for fields with high cardinality.
violation(high_cardinality_ordinal,E) :- type(E,ordinal), discrete_cardinality(E,C), C > 30.

% Prefer not to use nominal for fields with high cardinality.
violation(high_cardinality_nominal,E) :- type(E,nominal), enc_cardinality(E,C), C > 12.

% Prefer not to use high cardinality nominal for color.
violation(high_cardinality_nominal_color,E) :- type(E,nominal), channel(E,color), enc_cardinality(E,C), C > 10.

% Avoid high cardinality on x or column as it causes horizontal scrolling.
violation(horizontal_scrolling,E) :- channel(E,x), discrete_cardinality(E,C), C > 50.
violation(horizontal_scrolling,E) :- channel(E,columm), discrete_cardinality(E,C), C > 5.

% Prefer to use temporal type with dates.
violation(temporal_date,E) :- field(E,F), fieldtype(F,datetime), not type(E,temporal).

% Prefer quantitative for numbers with high cardinality.
violation(quantitative_numbers) :- field(E,F), fieldtype(F,number), cardinality(F,C), C > 20, not bin(E,_), not type(E,quantitative).

% Overplotting.

% Prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overplot.
violation(position_entropy,E) :- channel(E,(x;y)), continuous(E), enc_cardinality(E,C), C > 100, enc_entropy(E,EN), EN <= 12, not aggregate(E,_).

% Prefer not to use size when the cardinality is large on x or y.
violation(high_cardinality_size,E) :- continuous(E), channel(_,size), enc_cardinality(E,C), C > 100, channel(E,(x;y)).

% Prefer not to aggregate for value tasks.
violation(value_agg) :- task(value), aggregate(_,_).

% Prefer not to use row and column for summary tasks as it makes it difficult to compare.
violation(facet_summary,E) :- task(summary), channel(E,row).

% Positional interactions as suggested by Kim et al.
violation(x_row) :- channel(_,x), channel(_,row).
violation(y_row) :- channel(_,y), channel(_,row).
violation(x_column) :- channel(_,x), channel(_,column).
violation(y_column) :- channel(_,y), channel(_,column).

% Entropy, primary quantitaty interactions as suggested by Kim et al.
violation(color_entropy_high, E) :- channel(E,color), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).
violation(color_entropy_low, E) :- channel(E,color), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).
violation(size_entropy_high, E) :- channel(E,size), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).
violation(size_entropy_low, E) :- channel(E,size), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).

% Prefer not to use continuous on x, discrete on y, and column.
violation(c_d_column) :- channel_continuous(x), channel_discrete(y), channel(_,column).

% Prefer time on x.
violation(temporal_y) :- type(E,temporal), not channel(E,x).

% Prefer not to overlap with DxD.
violation(d_d_overlap) :- is_d_d, overlap.

% ====== Rankings ======

% === Data Types ===

% Prefer quantitative > ordinal > nominal.
violation(type_q,E) :- type(E,quantitative).
violation(type_o,E) :- type(E,ordinal).
violation(type_n,E) :- type(E,nominal).


% === Mark types ===

violation(c_c_point) :- is_c_c, mark(point).
violation(c_c_line) :- is_c_c, mark(line).
violation(c_c_area) :- is_c_c, mark(area).
violation(c_c_text) :- is_c_c, mark(text).
violation(c_c_tick) :- is_c_c, mark(tick).


violation(c_d_point) :- is_c_d, not no_overlap, mark(point).
violation(c_d_bar) :- is_c_d, not no_overlap, mark(bar).
violation(c_d_line) :- is_c_d, not no_overlap, mark(line).
violation(c_d_area) :- is_c_d, not no_overlap, mark(area).
violation(c_d_text) :- is_c_d, not no_overlap, mark(text).
violation(c_d_tick) :- is_c_d, not no_overlap, mark(tick).

violation(c_d_no_overlap_point) :- is_c_d, no_overlap, mark(point).
violation(c_d_no_overlap_bar) :- is_c_d, no_overlap, mark(bar).
violation(c_d_no_overlap_line) :- is_c_d, no_overlap, mark(line).
violation(c_d_no_overlap_area) :- is_c_d, no_overlap, mark(area).
violation(c_d_no_overlap_text) :- is_c_d, no_overlap, mark(text).
violation(c_d_no_overlap_tick) :- is_c_d, no_overlap, mark(tick).


violation(d_d_point) :- is_d_d, mark(point).
violation(d_d_text) :- is_d_d, mark(text).
violation(d_d_rect) :- is_d_d, mark(rect).


% === Channel rankings à la APT ===

violation(continuous_x,E) :- channel(E,x), continuous(E).
violation(continuous_y,E) :- channel(E,y), continuous(E).
violation(continuous_color,E) :- channel(E,color), continuous(E).
violation(continuous_size,E) :- channel(E,size), continuous(E).
violation(continuous_text,E) :- channel(E,text), continuous(E).

violation(ordered_x,E) :- channel(E,x), discrete(E), not type(E,nominal).
violation(ordered_y,E) :- channel(E,y), discrete(E), not type(E,nominal).
violation(ordered_color,E) :- channel(E,color), discrete(E), not type(E,nominal).
violation(ordered_size,E) :- channel(E,size), discrete(E), not type(E,nominal).
violation(ordered_text,E) :- channel(E,text), discrete(E), not type(E,nominal).
violation(ordered_row,E) :- channel(E,row), discrete(E), not type(E,nominal).
violation(ordered_column,E) :- channel(E,column), discrete(E), not type(E,nominal).

violation(nominal_x,E) :- channel(E,x), type(E,nominal).
violation(nominal_y,E) :- channel(E,y), type(E,nominal).
violation(nominal_color,E) :- channel(E,color), type(E,nominal).
violation(nominal_shape,E) :- channel(E,shape), type(E,nominal).
violation(nominal_text,E) :- channel(E,text), type(E,nominal).
violation(nominal_row,E) :- channel(E,row), type(E,nominal).
violation(nominal_column,E) :- channel(E,column), type(E,nominal).
violation(nominal_detail,E) :- channel(E,detail), type(E,nominal).

violation(interesting_x,E) :- channel(E,x), enc_interesting(E).
violation(interesting_y,E) :- channel(E,y), enc_interesting(E).
violation(interesting_color,E) :- channel(E,color), enc_interesting(E).
violation(interesting_size,E) :- channel(E,size), enc_interesting(E).
violation(interesting_shape,E) :- channel(E,shape), enc_interesting(E).
violation(interesting_text,E) :- channel(E,text), enc_interesting(E).
violation(interesting_row,E) :- channel(E,row), enc_interesting(E).
violation(interesting_column,E) :- channel(E,column), enc_interesting(E).
violation(interesting_detail,E) :- channel(E,detail), enc_interesting(E).

% === Aggregations ===

violation(aggregate_count,E) :- aggregate(E,count).
violation(aggregate_sum,E) :- aggregate(E,sum).
violation(aggregate_mean,E) :- aggregate(E,mean).
violation(aggregate_median,E) :- aggregate(E,median).
violation(aggregate_min,E) :- aggregate(E,min).
violation(aggregate_max,E) :- aggregate(E,max).
violation(aggregate_stdev,E) :- aggregate(E,stdev).


% === Stack ===

violation(stack_zero) :- stack(zero).
violation(stack_normalize) :- stack(normalize).


% === Task - marktype correlations ===

violation(value_point) :- task(value), mark(point).
violation(value_bar) :- task(value), mark(bar).
violation(value_line) :- task(value), mark(line).
violation(value_area) :- task(value), mark(area).
violation(value_text) :- task(value), mark(text).
violation(value_tick) :- task(value), mark(tick).
violation(value_rect) :- task(value), mark(rect).

violation(summary_point) :- task(summary), mark(point).
violation(summary_bar) :- task(summary), mark(bar).
violation(summary_line) :- task(summary), mark(line).
violation(summary_area) :- task(summary), mark(area).
violation(summary_text) :- task(summary), mark(text).
violation(summary_tick) :- task(summary), mark(tick).
violation(summary_rect) :- task(summary), mark(rect).


% === Task - channel correlations ===

violation(value_continuous_x,E) :- task(value), channel(E,x), continuous(E), enc_interesting(E).
violation(value_continuous_y,E) :- task(value), channel(E,y), continuous(E), enc_interesting(E).
violation(value_continuous_color,E) :- task(value), channel(E,color), continuous(E), enc_interesting(E).
violation(value_continuous_size,E) :- task(value), channel(E,size), continuous(E), enc_interesting(E).
violation(value_continuous_text,E) :- task(value), channel(E,text), continuous(E), enc_interesting(E).

violation(value_discrete_x,E) :- task(value), channel(E,x), discrete(E), enc_interesting(E).
violation(value_discrete_y,E) :- task(value), channel(E,y), discrete(E), enc_interesting(E).
violation(value_discrete_color,E) :- task(value), channel(E,color), discrete(E), enc_interesting(E).
violation(value_discrete_shape,E) :- task(value), channel(E,shape), discrete(E), enc_interesting(E).
violation(value_discrete_size,E) :- task(value), channel(E,size), discrete(E), enc_interesting(E).
violation(value_discrete_text,E) :- task(value), channel(E,text), discrete(E), enc_interesting(E).
violation(value_discrete_row,E) :- task(value), channel(E,row), discrete(E), enc_interesting(E).
violation(value_discrete_column,E) :- task(value), channel(E,column), discrete(E), enc_interesting(E).

violation(summary_continuous_x,E) :- task(summary), channel(E,x), continuous(E), enc_interesting(E).
violation(summary_continuous_y,E) :- task(summary), channel(E,y), continuous(E), enc_interesting(E).
violation(summary_continuous_color,E) :- task(summary), channel(E,color), continuous(E), enc_interesting(E).
violation(summary_continuous_size,E) :- task(summary), channel(E,size), continuous(E), enc_interesting(E).
violation(summary_continuous_text,E) :- task(summary), channel(E,text), continuous(E), enc_interesting(E).

violation(summary_discrete_x,E) :- task(summary), channel(E,x), discrete(E), enc_interesting(E).
violation(summary_discrete_y,E) :- task(summary), channel(E,y), discrete(E), enc_interesting(E).
violation(summary_discrete_color,E) :- task(summary), channel(E,color), discrete(E), enc_interesting(E).
violation(summary_discrete_shape,E) :- task(summary), channel(E,shape), discrete(E), enc_interesting(E).
violation(summary_discrete_size,E) :- task(summary), channel(E,size), discrete(E), enc_interesting(E).
violation(summary_discrete_text,E) :- task(summary), channel(E,text), discrete(E), enc_interesting(E).
violation(summary_discrete_row,E) :- task(summary), channel(E,row), discrete(E), enc_interesting(E).
violation(summary_discrete_column,E) :- task(summary), channel(E,column), discrete(E), enc_interesting(E).
