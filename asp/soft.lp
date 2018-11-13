% After adding a soft constraint to this file, make sure to update `weights.lp` and run `process_violations.py`..

% ====== Preferences ======

% @rule
% @type {violation}
% @description Prefer to use raw (no aggregate).
% @weight {1}
violation(aggregate,E) :- aggregate(E,_).
% @end

% @rule
% @type {violation}
% @description Prefer to not bin.
% @weight {2}

% @soft hello world
violation(bin,E) :- bin(E,_).

:- violation(bin,_).

% @rule
% @type {violation}
% @description Prefer binning with at most 12 buckets.
% @weight {10}
violation(bin_high,E) :- bin(E,B), B > 12.
% @end

% @rule
% @type {violation}
% @description Prefer binning with more than 7 buckets.
% @weight {6}
violation(bin_low,E) :- bin(E,B), B <= 7.
% @end

% @rule
% @type {violation}
% @description Prefer to use fewer encodings.
% @weight {0}
violation(encoding,E) :- encoding(E).
% @end

% @rule
% @type {violation}
% @description Prefer to use fewer encodings with fields (count does not have a field).
% @weight {6}
violation(encoding_field,E) :- encoding(E), field(E,_).
% @end

% @rule
% @type {violation}
% @description Prefer not to use the same field twice.
% @weight {8}
violation(same_field_2,F) :- field(F), { field(_,F) } = 2.
% @end

% @rule
% @type {violation}
% @description Prefer not to use the same field three or more times.
% @weight {16}
violation(same_field_gte3,F) :- field(F), { field(_,F) } >= 3.
% @end

% @rule
% @type {violation}
% @description Prefer not to use count more than once.
% @weight {50}
violation(count_twice) :- { aggregate(_,count) } = 2.
% @end

% @rule
% @type {violation}
% @description Shape channel should not have too high cardinality.
% @weight {5}
violation(shape_cardinality,E) :- channel(E,shape), discrete_cardinality(E,C), C > 5.
% @end

% @rule
% @type {violation}
% @description Numbers should not be nominal.
% @weight {10}
violation(number_nominal,E) :- type(E,nominal), field(E,F), fieldtype(F,number).
% @end

% @rule
% @type {violation}
% @description Binned quantitative field should not have too low cardinality.
% @weight {5}
violation(bin_cardinality,E) :- type(E,quantitative), bin(E,_), enc_cardinality(E,C), C < 15.
% @end

% @rule
% @type {violation}
% @description Prefer quantitative for bin.
% @weight {1}
violation(quant_bin,E) :- bin(E,_), not type(E,quantitative).
% @end

% @rule
% @type {violation}
% @description Plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field.
% @weight {30}
violation(only_discrete) :- not continuous(_).
% @end

% @rule
% @type {violation}
% @description Prefer not to use multiple non-positional encoding channels.
% @weight {3}
violation(multiple_non_pos) :- {channel(_,C): non_positional(C)} > 1.
% @end

% @rule
% @type {violation}
% @description Prefer not to use non-positional channels until all positional channels are used.
% @weight {3}
violation(non_positional_pref) :- channel(_,C), non_positional(C), not channel(_,(x;y)).
% @end

% @rule
% @type {violation}
% @description Aggregate plots should not use raw continuous as group by.
% @weight {3}
violation(aggregate_group_by_raw,E) :- aggregate(_,_), continuous(E), not aggregate(E,_).
% @end

% @rule
% @type {violation}
% @description Aggregate should also have a discrete encoding to group by.
% @weight {2}
violation(agg_dim) :- aggregate(_,_), not discrete(_).
% @end

% @rule
% @type {violation}
% @description Prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion.
% @weight {1}
violation(x_y_raw,E) :- channel(EX,x), discrete(EX), channel(EY,y), discrete(EY), not aggregate(E,_), continuous(E).
% @end

% @rule
% @type {violation}
% @description Prefer not to use log scale.
% @weight {1}
violation(log,E) :- log(E).
% @end

% @rule
% @type {violation}
% @description Prefer to include zero for continuous (binned doesn't need zero).
% @weight {1}
violation(zero,E) :- continuous(E), not zero(E).
% @end

% @rule
% @type {violation}
% @description Prefer zero size (even when binned).
% @weight {1}
violation(zero_size) :- channel(E,size), not zero(E).
% @end

% @rule
% @type {violation}
% @description Prefer zero positional.
% @weight {1}
violation(zero_positional) :- continuous(E), channel(E,(x;y)), not zero(E).
% @end

% @rule
% @type {violation}
% @description Prefer not to use zero when the difference between min and max is larger than distance to 0.
% @weight {5}
violation(zero_skew) :- enc_extent(E,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX, zero(E).
% @end

% @rule
% @type {violation}
% @description Do not include zero when the range of data includes zero.
% @weight {10}
violation(includes_zero) :- zero(E), extent(E,MIN,MAX), MIN < 0, MAX > 0.
% @end

% @rule
% @type {violation}
% @description Prefer to use only x instead of only y.
% @weight {1}
violation(only_x) :- channel(_,y), not channel(_,x).
% @end

% @rule
% @type {violation}
% @description Chart orientation for bar and tick (with and without bin). Binned fields have short labels if they are quantitative while otherwise labels can be long.
% @weight {1}
violation(orientation_binned) :- bin(E,_), type(E,quantitative), not channel(E,x).
% @end

% @rule
% @type {violation}
% @description Prefer not to use ordinal for fields with high cardinality.
% @weight {10}
violation(high_cardinality_ordinal,E) :- type(E,ordinal), discrete_cardinality(E,C), C > 30.
% @end

% @rule
% @type {violation}
% @description Prefer not to use nominal for fields with high cardinality.
% @weight {10}
violation(high_cardinality_nominal,E) :- type(E,nominal), enc_cardinality(E,C), C > 12.
% @end

% @rule
% @type {violation}
% @description Prefer not to use high cardinality nominal for color.
% @weight {10}
violation(high_cardinality_nominal_color,E) :- type(E,nominal), channel(E,color), enc_cardinality(E,C), C > 10.
% @end

% @rule
% @type {violation}
% @description Avoid high cardinality on x or column as it causes horizontal scrolling.
% @weight {20}
violation(horizontal_scrolling,E) :- channel(E,x), discrete_cardinality(E,C), C > 50.
violation(horizontal_scrolling,E) :- channel(E,columm), discrete_cardinality(E,C), C > 5.
% @end

% @rule
% @type {violation}
% @description Prefer to use temporal type with dates.
% @weight {1}
violation(temporal_date,E) :- field(E,F), fieldtype(F,datetime), not type(E,temporal).
% @end

% @rule
% @type {violation}
% @description Prefer quantitative for numbers with high cardinality.
% @weight {2}
violation(quantitative_numbers) :- field(E,F), fieldtype(F,number), cardinality(F,C), C > 20, not bin(E,_), not type(E,quantitative).
% @end

% @rule
% @type {violation}
% @description Overplotting. Prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overplot.
% @weight {2}
violation(position_entropy,E) :- channel(E,(x;y)), continuous(E), enc_cardinality(E,C), C > 100, enc_entropy(E,EN), EN <= 12, not aggregate(E,_).
% @end

% @rule
% @type {violation}
% @description Prefer not to use size when the cardinality is large on x or y.
% @weight {1}
violation(high_cardinality_size,E) :- continuous(E), channel(_,size), enc_cardinality(E,C), C > 100, channel(E,(x;y)).
% @end

% @rule
% @type {violation}
% @description Prefer not to aggregate for value tasks.
% @weight {1}
violation(value_agg) :- task(value), aggregate(_,_).
% @end

% @rule
% @type {violation}
% @description Prefer not to use row and column for summary tasks as it makes it difficult to compare.
% @weight {0}
violation(facet_summary,E) :- task(summary), channel(E,row).
% @end

% @rule
% @type {violation}
% @description Positional interactions as suggested by Kim et al.
% @weight {1}
violation(x_row) :- channel(_,x), channel(_,row).
% @end

% @rule
% @type {violation}
% @description Positional interactions as suggested by Kim et al.
% @weight {1}
violation(y_row) :- channel(_,y), channel(_,row).
% @end

% @rule
% @type {violation}
% @description Positional interactions as suggested by Kim et al.
% @weight {1}
violation(x_column) :- channel(_,x), channel(_,column).
% @end

% @rule
% @type {violation}
% @description Positional interactions as suggested by Kim et al.
% @weight {1}
violation(y_column) :- channel(_,y), channel(_,column).
% @end

% @rule
% @type {violation}
% @description Entropy, primary quantitaty interactions as suggested by Kim et al.
% @weight {0}
violation(color_entropy_high, E) :- channel(E,color), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Entropy, primary quantitaty interactions as suggested by Kim et al.
% @weight {0}
violation(color_entropy_low, E) :- channel(E,color), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Entropy, primary quantitaty interactions as suggested by Kim et al.
% @weight {0}
violation(size_entropy_high, E) :- channel(E,size), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Entropy, primary quantitaty interactions as suggested by Kim et al.
% @weight {0}
violation(size_entropy_low, E) :- channel(E,size), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Prefer not to use continuous on x, discrete on y, and column.
% @weight {5}
violation(c_d_column) :- channel_continuous(x), channel_discrete(y), channel(_,column).
% @end

% @rule
% @type {violation}
% @description Prefer time on x.
% @weight {1}
violation(temporal_y) :- type(E,temporal), not channel(E,x).
% @end

% @rule
% @type {violation}
% @description Prefer not to overlap with DxD.
% @weight {20}
violation(d_d_overlap) :- is_d_d, overlap.
% @end

% ====== Rankings ======
% === Data Types ===

% @rule
% @type {violation}
% @description Prefer quantitative > ordinal > nominal.
% @weight {0}
violation(type_q,E) :- type(E,quantitative).
% @end

% @rule
% @type {violation}
% @description Prefer quantitative > ordinal > nominal.
% @weight {1}
violation(type_o,E) :- type(E,ordinal).
% @end

% @rule
% @type {violation}
% @description Prefer quantitative > ordinal > nominal.
% @weight {2}
violation(type_n,E) :- type(E,nominal).
% @end

% === Mark types ===

% @rule
% @type {violation}
% @description Continuous by continuous for point mark.
% @weight {0}
violation(c_c_point) :- is_c_c, mark(point).
% @end

% @rule
% @type {violation}
% @description Continuous by continuous for line mark.
% @weight {20}
violation(c_c_line) :- is_c_c, mark(line).
% @end

% @rule
% @type {violation}
% @description Continuous by continuous for area mark.
% @weight {20}
violation(c_c_area) :- is_c_c, mark(area).
% @end

% @rule
% @type {violation}
% @description Continuous by continuous for text mark.
% @weight {2}
violation(c_c_text) :- is_c_c, mark(text).
% @end

% @rule
% @type {violation}
% @description Continuous by continuous for tick mark.
% @weight {5}
violation(c_c_tick) :- is_c_c, mark(tick).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for point mark.
% @weight {10}
violation(c_d_point) :- is_c_d, not no_overlap, mark(point).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for bar mark.
% @weight {20}
violation(c_d_bar) :- is_c_d, not no_overlap, mark(bar).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for line mark.
% @weight {20}
violation(c_d_line) :- is_c_d, not no_overlap, mark(line).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for area mark.
% @weight {20}
violation(c_d_area) :- is_c_d, not no_overlap, mark(area).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for text mark.
% @weight {50}
violation(c_d_text) :- is_c_d, not no_overlap, mark(text).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for tick mark.
% @weight {0}
violation(c_d_tick) :- is_c_d, not no_overlap, mark(tick).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for point mark with no overlap.
% @weight {20}
violation(c_d_no_overlap_point) :- is_c_d, no_overlap, mark(point).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for bar mark with no overlap.
% @weight {0}
violation(c_d_no_overlap_bar) :- is_c_d, no_overlap, mark(bar).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for line mark with no overlap.
% @weight {20}
violation(c_d_no_overlap_line) :- is_c_d, no_overlap, mark(line).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for area mark with no overlap.
% @weight {20}
violation(c_d_no_overlap_area) :- is_c_d, no_overlap, mark(area).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for text mark with no overlap.
% @weight {30}
violation(c_d_no_overlap_text) :- is_c_d, no_overlap, mark(text).
% @end

% @rule
% @type {violation}
% @description Continuous by discrete for tick mark with no overlap.
% @weight {25}
violation(c_d_no_overlap_tick) :- is_c_d, no_overlap, mark(tick).
% @end

% @rule
% @type {violation}
% @description Discrete by discrete for point mark.
% @weight {0}
violation(d_d_point) :- is_d_d, mark(point).
% @end

% @rule
% @type {violation}
% @description Discrete by discrete for point mark.
% @weight {0}
violation(d_d_text) :- is_d_d, mark(text).
% @end

% @rule
% @type {violation}
% @description Discrete by discrete for point mark.
% @weight {0}
violation(d_d_rect) :- is_d_d, mark(rect).
% @end

% === Channel rankings à la APT ===

% @rule
% @type {violation}
% @description Continuous on x channel.
% @weight {0}
violation(continuous_x,E) :- channel(E,x), continuous(E).
% @end

% @rule
% @type {violation}
% @description Continuous on y channel.
% @weight {0}
violation(continuous_y,E) :- channel(E,y), continuous(E).
% @end

% @rule
% @type {violation}
% @description Continuous on color channel.
% @weight {10}
violation(continuous_color,E) :- channel(E,color), continuous(E).
% @end

% @rule
% @type {violation}
% @description Continuous on size channel.
% @weight {1}
violation(continuous_size,E) :- channel(E,size), continuous(E).
% @end

% @rule
% @type {violation}
% @description Continuous on text channel.
% @weight {20}
violation(continuous_text,E) :- channel(E,text), continuous(E).
% @end

% @rule
% @type {violation}
% @description Ordered on x channel.
% @weight {1}
violation(ordered_x,E) :- channel(E,x), discrete(E), not type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Ordered on y channel.
% @weight {0}
violation(ordered_y,E) :- channel(E,y), discrete(E), not type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Ordered on color channel.
% @weight {8}
violation(ordered_color,E) :- channel(E,color), discrete(E), not type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Ordered on size channel.
% @weight {10}
violation(ordered_size,E) :- channel(E,size), discrete(E), not type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Ordered on text channel.
% @weight {32}
violation(ordered_text,E) :- channel(E,text), discrete(E), not type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Ordered on row channel.
% @weight {10}
violation(ordered_row,E) :- channel(E,row), discrete(E), not type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Ordered on column channel.
% @weight {10}
violation(ordered_column,E) :- channel(E,column), discrete(E), not type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Nominal on x channel.
% @weight {3}
violation(nominal_x,E) :- channel(E,x), type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Nominal on y channel.
% @weight {0}
violation(nominal_y,E) :- channel(E,y), type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Nominal on color channel.
% @weight {8}
violation(nominal_color,E) :- channel(E,color), type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Nominal on shape channel.
% @weight {11}
violation(nominal_shape,E) :- channel(E,shape), type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Nominal on text channel.
% @weight {12}
violation(nominal_text,E) :- channel(E,text), type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Nominal on row channel.
% @weight {7}
violation(nominal_row,E) :- channel(E,row), type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Nominal on column channel.
% @weight {10}
violation(nominal_column,E) :- channel(E,column), type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Nominal on detail channel.
% @weight {20}
violation(nominal_detail,E) :- channel(E,detail), type(E,nominal).
% @end

% @rule
% @type {violation}
% @description Interesting on x channel.
% @weight {0}
violation(interesting_x,E) :- channel(E,x), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Interesting on y channel.
% @weight {1}
violation(interesting_y,E) :- channel(E,y), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Interesting on color channel.
% @weight {2}
violation(interesting_color,E) :- channel(E,color), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Interesting on size channel.
% @weight {2}
violation(interesting_size,E) :- channel(E,size), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Interesting on shape channel.
% @weight {3}
violation(interesting_shape,E) :- channel(E,shape), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Interesting on text channel.
% @weight {6}
violation(interesting_text,E) :- channel(E,text), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Interesting on row channel.
% @weight {6}
violation(interesting_row,E) :- channel(E,row), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Interesting on column channel.
% @weight {7}
violation(interesting_column,E) :- channel(E,column), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Interesting on detail channel.
% @weight {20}
violation(interesting_detail,E) :- channel(E,detail), enc_interesting(E).
% @end

% === Aggregations ===

% @rule
% @type {violation}
% @description Count as aggregate op.
% @weight {0}
violation(aggregate_count,E) :- aggregate(E,count).
% @end

% @rule
% @type {violation}
% @description Sum as aggregate op.
% @weight {2}
violation(aggregate_sum,E) :- aggregate(E,sum).

% @end

% @rule
% @type {violation}
% @description Mean as aggregate op.
% @weight {1}
violation(aggregate_mean,E) :- aggregate(E,mean).

% @end

% @rule
% @type {violation}
% @description Median as aggregate op.
% @weight {3}
violation(aggregate_median,E) :- aggregate(E,median).
% @end

% @rule
% @type {violation}
% @description Min as aggregate op.
% @weight {4}
violation(aggregate_min,E) :- aggregate(E,min).
% @end

% @rule
% @type {violation}
% @description Max as aggregate op.
% @weight {4}
violation(aggregate_max,E) :- aggregate(E,max).
% @end

% @rule
% @type {violation}
% @description Standard Deviation as aggregate op.
% @weight {5}
violation(aggregate_stdev,E) :- aggregate(E,stdev).
% @end

% === Stack ===

% @rule
% @type {violation}
% @description Zero base for stack op.
% @weight {0}
violation(stack_zero) :- stack(zero).
% @end

% @rule
% @type {violation}
% @description Normalize between groupbys as stack op.
% @weight {1}
violation(stack_normalize) :- stack(normalize).
% @end

% === Task - marktype correlations ===

% @rule
% @type {violation}
% @description Point mark for value tasks.
% @weight {0}
violation(value_point) :- task(value), mark(point).
% @end

% @rule
% @type {violation}
% @description Bar mark for value tasks.
% @weight {0}
violation(value_bar) :- task(value), mark(bar).
% @end

% @rule
% @type {violation}
% @description Line mark for value tasks.
% @weight {0}
violation(value_line) :- task(value), mark(line).
% @end

% @rule
% @type {violation}
% @description Area mark for value tasks.
% @weight {0}
violation(value_area) :- task(value), mark(area).
% @end

% @rule
% @type {violation}
% @description Text mark for value tasks.
% @weight {0}
violation(value_text) :- task(value), mark(text).
% @end

% @rule
% @type {violation}
% @description Tick mark for value tasks.
% @weight {0}
violation(value_tick) :- task(value), mark(tick).
% @end

% @rule
% @type {violation}
% @description Rect mark for value tasks.
% @weight {0}
violation(value_rect) :- task(value), mark(rect).
% @end

% @rule
% @type {violation}
% @description Point mark for summary tasks.
% @weight {0}
violation(summary_point) :- task(summary), mark(point).
% @end

% @rule
% @type {violation}
% @description Bar mark for summary tasks.
% @weight {0}
violation(summary_bar) :- task(summary), mark(bar).
% @end

% @rule
% @type {violation}
% @description Line mark for summary tasks.
% @weight {0}
violation(summary_line) :- task(summary), mark(line).
% @end

% @rule
% @type {violation}
% @description Area mark for summary tasks.
% @weight {0}
violation(summary_area) :- task(summary), mark(area).
% @end

% @rule
% @type {violation}
% @description Text mark for summary tasks.
% @weight {0}
violation(summary_text) :- task(summary), mark(text).
% @end

% @rule
% @type {violation}
% @description Tick mark for summary tasks.
% @weight {0}
violation(summary_tick) :- task(summary), mark(tick).
% @end

% @rule
% @type {violation}
% @description Rect mark for summary tasks.
% @weight {0}
violation(summary_rect) :- task(summary), mark(rect).
% @end

% === Task - channel correlations ===

% @rule
% @type {violation}
% @description Continuous x for value tasks.
% @weight {0}
violation(value_continuous_x,E) :- task(value), channel(E,x), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous y for value tasks.
% @weight {0}
violation(value_continuous_y,E) :- task(value), channel(E,y), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous color for value tasks.
% @weight {0}
violation(value_continuous_color,E) :- task(value), channel(E,color), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous size for value tasks.
% @weight {0}
violation(value_continuous_size,E) :- task(value), channel(E,size), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous text for value tasks.
% @weight {0}
violation(value_continuous_text,E) :- task(value), channel(E,text), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete x for value tasks.
% @weight {0}
violation(value_discrete_x,E) :- task(value), channel(E,x), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete y for value tasks.
% @weight {0}
violation(value_discrete_y,E) :- task(value), channel(E,y), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete color for value tasks.
% @weight {0}
violation(value_discrete_color,E) :- task(value), channel(E,color), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete shape for value tasks.
% @weight {0}
violation(value_discrete_shape,E) :- task(value), channel(E,shape), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete size for value tasks.
% @weight {0}
violation(value_discrete_size,E) :- task(value), channel(E,size), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete text for value tasks.
% @weight {0}
violation(value_discrete_text,E) :- task(value), channel(E,text), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete row for value tasks.
% @weight {0}
violation(value_discrete_row,E) :- task(value), channel(E,row), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete column for value tasks.
% @weight {0}
violation(value_discrete_column,E) :- task(value), channel(E,column), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous x for summary tasks.
% @weight {0}
violation(summary_continuous_x,E) :- task(summary), channel(E,x), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous y for summary tasks.
% @weight {0}
violation(summary_continuous_y,E) :- task(summary), channel(E,y), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous color for summary tasks.
% @weight {0}
violation(summary_continuous_color,E) :- task(summary), channel(E,color), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous size for summary tasks.
% @weight {0}
violation(summary_continuous_size,E) :- task(summary), channel(E,size), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Continuous text for summary tasks.
% @weight {0}
violation(summary_continuous_text,E) :- task(summary), channel(E,text), continuous(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete x for summary tasks.
% @weight {0}
violation(summary_discrete_x,E) :- task(summary), channel(E,x), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete y for summary tasks.
% @weight {0}
violation(summary_discrete_y,E) :- task(summary), channel(E,y), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete color for summary tasks.
% @weight {0}
violation(summary_discrete_color,E) :- task(summary), channel(E,color), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete shape for summary tasks.
% @weight {0}
violation(summary_discrete_shape,E) :- task(summary), channel(E,shape), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete size for summary tasks.
% @weight {0}
violation(summary_discrete_size,E) :- task(summary), channel(E,size), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete text for summary tasks.
% @weight {0}
violation(summary_discrete_text,E) :- task(summary), channel(E,text), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete row for summary tasks.
% @weight {0}
violation(summary_discrete_row,E) :- task(summary), channel(E,row), discrete(E), enc_interesting(E).
% @end

% @rule
% @type {violation}
% @description Discrete column for summary tasks.
% @weight {0}
violation(summary_discrete_column,E) :- task(summary), channel(E,column), discrete(E), enc_interesting(E).
% @end