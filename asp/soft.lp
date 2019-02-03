% After adding a soft constraint to this file, make sure to update `weights.lp` and run `process_softs.py`..

% ====== Preferences ======

% @constraint Prefer to use raw (no aggregate).
soft(aggregate,V,E) :- aggregate(V,E,_).

% @constraint Prefer to not bin.
soft(bin,V,E) :- bin(V,E,_).

% @constraint Prefer binning with at most 12 buckets.
soft(bin_high,V,E) :- bin(V,E,B), B > 12.

% @constraint Prefer binning with more than 7 buckets.
soft(bin_low,V,E) :- bin(V,E,B), B <= 7.

% @constraint Prefer to use fewer encodings.
soft(encoding,V,E) :- encoding(V,E).

% @constraint Prefer to use fewer encodings with fields (count does not have a field).
soft(encoding_field,V,E) :- field(V,E,_).

% @constraint Prefer not to use the same field twice.
soft(same_field_2,V,F) :- visualization(V), field(F), { field(V,_,F) } = 2.

% @constraint Prefer not to use the same field three or more times.
soft(same_field_gte3,V,F) :- visualization(V), field(F), { field(V,_,F) } >= 3.

% @constraint Prefer not to use count more than once.
soft(count_twice,V) :- visualization(V), { aggregate(V,_,count) } = 2.

% @constraint Shape channel should not have too high cardinality.
soft(shape_cardinality,V,E) :- channel(V,E,shape), discrete_cardinality(V,E,C), C > 5.

% @constraint Numbers should not be nominal.
soft(number_nominal,V,E) :- type(V,E,nominal), field(V,E,F), fieldtype(F,number).

% @constraint Binned quantitative field should not have too low cardinality.
soft(bin_cardinality,V,E) :- type(V,E,quantitative), bin(V,E,_), enc_cardinality(V,E,C), C < 15.

% @constraint Prefer quantitative for bin.
soft(quant_bin,V,E) :- bin(V,E,_), not type(V,E,quantitative).

% @constraint Plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field.
soft(only_discrete,V) :- visualization(V), not continuous(V,_).

% @constraint Prefer not to use multiple non-positional encoding channels.
soft(multiple_non_pos,V) :- visualization(V), { channel(V,_,C): non_positional(C) } > 1.

% @constraint Prefer not to use non-positional channels until all positional channels are used.
soft(non_positional_pref,V) :- channel(V,_,C), non_positional(C), not channel(V,_,(x;y)).

% @constraint Aggregate plots should not use raw continuous as group by.
soft(aggregate_group_by_raw,E) :- aggregate(V,_,_), continuous(V,E), not aggregate(V,E,_).

% @constraint Aggregate should also have a discrete encoding to group by.
soft(agg_dim,V) :- aggregate(V,_,_), not discrete(V,_).

% @constraint Prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion.
soft(x_y_raw,V,E) :- channel(V,EX,x), discrete(V,EX), channel(V,EY,y), discrete(V,EY), encoding(V,E), not aggregate(V,E,_), continuous(V,E).

% @constraint Prefer not to use log scale.
soft(log,V,E) :- log(V,E).

% @constraint Prefer to include zero for continuous (binned doesn't need zero).
soft(zero,V,E) :- continuous(V,E), not zero(V,E).

% @constraint Prefer zero size (even when binned).
soft(zero_size,V) :- channel(V,E,size), not zero(V,E).

% @constraint Prefer zero positional.
soft(zero_positional,V) :- continuous(V,E), channel(V,E,(x;y)), not zero(V,E).

% @constraint Prefer not to use zero when the difference between min and max is larger than distance to 0.
soft(zero_skew,V) :- enc_extent(V,E,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX, zero(V,E).

% @constraint Do not include zero when the range of data includes zero.
soft(includes_zero,V,E) :- zero(V,E), field(V,E,F), extent(F,MIN,MAX), MIN < 0, MAX > 0.

% @constraint Prefer to use only x instead of only y.
soft(only_x,V) :- channel(V,_,y), not channel(V,_,x).

% @constraint Chart orientation for bar and tick (with and without bin). Binned fields have short labels if they are quantitative while otherwise labels can be long.
soft(orientation_binned,V) :- bin(V,E,_), type(V,E,quantitative), not channel(V,E,x).

% @constraint Prefer not to use ordinal for fields with high cardinality.
soft(high_cardinality_ordinal,V,E) :- type(V,E,ordinal), discrete_cardinality(V,E,C), C > 30.

% @constraint Prefer not to use nominal for fields with high cardinality.
soft(high_cardinality_nominal,V,E) :- type(V,E,nominal), enc_cardinality(V,E,C), C > 12.

% @constraint Prefer not to use high cardinality nominal for color.
soft(high_cardinality_nominal_color,V,E) :- type(V,E,nominal), channel(V,E,color), enc_cardinality(V,E,C), C > 10.

% @constraint Avoid high cardinality on x or column as it causes horizontal scrolling.
soft(horizontal_scrolling,V,E) :- channel(V,E,x), discrete_cardinality(V,E,C), C > 50.
soft(horizontal_scrolling,V,E) :- channel(V,E,columm), discrete_cardinality(V,E,C), C > 5.

% @constraint Prefer to use temporal type with dates.
soft(temporal_date,V,E) :- field(V,E,F), fieldtype(F,datetime), not type(V,E,temporal).

% @constraint Prefer quantitative for numbers with high cardinality.
soft(quantitative_numbers,V) :- field(V,E,F), fieldtype(F,number), cardinality(F,C), C > 20, not bin(V,E,_), not type(V,E,quantitative).

% @constraint Overplotting. Prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overplot.
soft(position_entropy,V,E) :- channel(V,E,(x;y)), continuous(V,E), enc_cardinality(V,E,C), C > 100, enc_entropy(V,E,EN), EN <= 12, not aggregate(V,E,_).

% @constraint Prefer not to use size when the cardinality is large on x or y.
soft(high_cardinality_size,V,E) :- continuous(V,E), channel(V,_,size), enc_cardinality(V,E,C), C > 100, channel(V,E,(x;y)).

% @constraint Prefer not to aggregate for value tasks.
soft(value_agg,V) :- task(V,value), aggregate(V,_,_).

% @constraint Prefer not to use row and column for summary tasks as it makes it difficult to compare.
soft(facet_summary,V,E) :- task(V,summary), channel(V,E,row).

% @constraint Positional interactions as suggested by Kim et al.
soft(x_row,V) :- channel(V,_,x), channel(V,_,row).

% @constraint Positional interactions as suggested by Kim et al.
soft(y_row,V) :- channel(V,_,y), channel(V,_,row).

% @constraint Positional interactions as suggested by Kim et al.
soft(x_column,V) :- channel(V,_,x), channel(V,_,column).

% @constraint Positional interactions as suggested by Kim et al.
soft(y_column,V) :- channel(V,_,y), channel(V,_,column).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_high,V,E) :- channel(V,E,color), enc_entropy(V,E,EN), EN > 12, type(V,E,quantitative), enc_interesting(V,E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_low,V,E) :- channel(V,E,color), enc_entropy(V,E,EN), EN <= 12, type(V,E,quantitative), enc_interesting(V,E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(size_entropy_high,V,E) :- channel(V,E,size), enc_entropy(V,E,EN), EN > 12, type(V,E,quantitative), enc_interesting(V,E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(size_entropy_low,V,E) :- channel(V,E,size), enc_entropy(V,E,EN), EN <= 12, type(V,E,quantitative), enc_interesting(V,E).

% @constraint Prefer not to use continuous on x, discrete on y, and column.
soft(c_d_column,V) :- channel_continuous(V,x), channel_discrete(V,y), channel(V,_,column).

% @constraint Prefer time on x.
soft(temporal_y,V) :- type(V,E,temporal), not channel(V,E,x).

% @constraint Prefer not to overlap with DxD.
soft(d_d_overlap,V) :- is_d_d(V), overlap(V).

% ====== Rankings ======
% === Data Types ===

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_q,V,E) :- type(V,E,quantitative).

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_o,V,E) :- type(V,E,ordinal).

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_n,V,E) :- type(V,E,nominal).

% === Mark types ===

% @constraint Continuous by continuous for point mark.
soft(c_c_point,V) :- is_c_c(V), mark(V,point).

% @constraint Continuous by continuous for line mark.
soft(c_c_line,V) :- is_c_c(V), mark(V,line).

% @constraint Continuous by continuous for area mark.
soft(c_c_area,V) :- is_c_c(V), mark(V,area).

% @constraint Continuous by continuous for text mark.
soft(c_c_text,V) :- is_c_c(V), mark(V,text).

% @constraint Continuous by continuous for tick mark.
soft(c_c_tick,V) :- is_c_c(V), mark(V,tick).

% @constraint Continuous by discrete for point mark.
soft(c_d_point,V) :- is_c_d(V), not no_overlap(V), mark(V,point).

% @constraint Continuous by discrete for bar mark.
soft(c_d_bar,V) :- is_c_d(V), not no_overlap(V), mark(V,bar).

% @constraint Continuous by discrete for line mark.
soft(c_d_line,V) :- is_c_d(V), not no_overlap(V), mark(V,line).

% @constraint Continuous by discrete for area mark.
soft(c_d_area,V) :- is_c_d(V), not no_overlap(V), mark(V,area).

% @constraint Continuous by discrete for text mark.
soft(c_d_text,V) :- is_c_d(V), not no_overlap(V), mark(V,text).

% @constraint Continuous by discrete for tick mark.
soft(c_d_tick,V) :- is_c_d(V), not no_overlap(V), mark(V,tick).

% @constraint Continuous by discrete for point mark with no overlap.
soft(c_d_no_overlap_point,V) :- is_c_d(V), no_overlap(V), mark(V,point).

% @constraint Continuous by discrete for bar mark with no overlap.
soft(c_d_no_overlap_bar,V) :- is_c_d(V), no_overlap(V), mark(V,bar).

% @constraint Continuous by discrete for line mark with no overlap.
soft(c_d_no_overlap_line,V) :- is_c_d(V), no_overlap(V), mark(V,line).

% @constraint Continuous by discrete for area mark with no overlap.
soft(c_d_no_overlap_area,V) :- is_c_d(V), no_overlap(V), mark(V,area).

% @constraint Continuous by discrete for text mark with no overlap.
soft(c_d_no_overlap_text,V) :- is_c_d(V), no_overlap(V), mark(V,text).

% @constraint Continuous by discrete for tick mark with no overlap.
soft(c_d_no_overlap_tick,V) :- is_c_d(V), no_overlap(V), mark(V,tick).

% @constraint Discrete by discrete for point mark.
soft(d_d_point,V) :- is_d_d(V), mark(V,point).

% @constraint Discrete by discrete for point mark.
soft(d_d_text,V) :- is_d_d(V), mark(V,text).

% @constraint Discrete by discrete for point mark.
soft(d_d_rect,V) :- is_d_d(V), mark(V,rect).

% === Channel rankings à la APT ===

% @constraint Continuous on x channel.
soft(continuous_x,V,E) :- channel(V,E,x), continuous(V,E).

% @constraint Continuous on y channel.
soft(continuous_y,V,E) :- channel(V,E,y), continuous(V,E).

% @constraint Continuous on color channel.
soft(continuous_color,V,E) :- channel(V,E,color), continuous(V,E).

% @constraint Continuous on size channel.
soft(continuous_size,V,E) :- channel(V,E,size), continuous(V,E).

% @constraint Continuous on text channel.
soft(continuous_text,V,E) :- channel(V,E,text), continuous(V,E).

% @constraint Ordered on x channel.
soft(ordered_x,V,E) :- channel(V,E,x), discrete(V,E), not type(V,E,nominal).

% @constraint Ordered on y channel.
soft(ordered_y,V,E) :- channel(V,E,y), discrete(V,E), not type(V,E,nominal).

% @constraint Ordered on color channel.
soft(ordered_color,V,E) :- channel(V,E,color), discrete(V,E), not type(V,E,nominal).

% @constraint Ordered on size channel.
soft(ordered_size,V,E) :- channel(V,E,size), discrete(V,E), not type(V,E,nominal).

% @constraint Ordered on text channel.
soft(ordered_text,V,E) :- channel(V,E,text), discrete(V,E), not type(V,E,nominal).

% @constraint Ordered on row channel.
soft(ordered_row,V,E) :- channel(V,E,row), discrete(V,E), not type(V,E,nominal).

% @constraint Ordered on column channel.
soft(ordered_column,V,E) :- channel(V,E,column), discrete(V,E), not type(V,E,nominal).

% @constraint Nominal on x channel.
soft(nominal_x,V,E) :- channel(V,E,x), type(V,E,nominal).

% @constraint Nominal on y channel.
soft(nominal_y,V,E) :- channel(V,E,y), type(V,E,nominal).

% @constraint Nominal on color channel.
soft(nominal_color,V,E) :- channel(V,E,color), type(V,E,nominal).

% @constraint Nominal on shape channel.
soft(nominal_shape,V,E) :- channel(V,E,shape), type(V,E,nominal).

% @constraint Nominal on text channel.
soft(nominal_text,V,E) :- channel(V,E,text), type(V,E,nominal).

% @constraint Nominal on row channel.
soft(nominal_row,V,E) :- channel(V,E,row), type(V,E,nominal).

% @constraint Nominal on column channel.
soft(nominal_column,V,E) :- channel(V,E,column), type(V,E,nominal).

% @constraint Nominal on detail channel.
soft(nominal_detail,V,E) :- channel(V,E,detail), type(V,E,nominal).

% @constraint Interesting on x channel.
soft(interesting_x,V,E) :- channel(V,E,x), enc_interesting(V,E).

% @constraint Interesting on y channel.
soft(interesting_y,V,E) :- channel(V,E,y), enc_interesting(V,E).

% @constraint Interesting on color channel.
soft(interesting_color,V,E) :- channel(V,E,color), enc_interesting(V,E).

% @constraint Interesting on size channel.
soft(interesting_size,V,E) :- channel(V,E,size), enc_interesting(V,E).

% @constraint Interesting on shape channel.
soft(interesting_shape,V,E) :- channel(V,E,shape), enc_interesting(V,E).

% @constraint Interesting on text channel.
soft(interesting_text,V,E) :- channel(V,E,text), enc_interesting(V,E).

% @constraint Interesting on row channel.
soft(interesting_row,V,E) :- channel(V,E,row), enc_interesting(V,E).

% @constraint Interesting on column channel.
soft(interesting_column,V,E) :- channel(V,E,column), enc_interesting(V,E).

% @constraint Interesting on detail channel.
soft(interesting_detail,V,E) :- channel(V,E,detail), enc_interesting(V,E).

% === Aggregations ===

% @constraint Count as aggregate op.
soft(aggregate_count,V,E) :- aggregate(V,E,count).

% @constraint Sum as aggregate op.
soft(aggregate_sum,V,E) :- aggregate(V,E,sum).

% @constraint Mean as aggregate op.
soft(aggregate_mean,V,E) :- aggregate(V,E,mean).

% @constraint Median as aggregate op.
soft(aggregate_median,V,E) :- aggregate(V,E,median).

% @constraint Min as aggregate op.
soft(aggregate_min,V,E) :- aggregate(V,E,min).

% @constraint Max as aggregate op.
soft(aggregate_max,V,E) :- aggregate(V,E,max).

% @constraint Standard Deviation as aggregate op.
soft(aggregate_stdev,V,E) :- aggregate(V,E,stdev).

% === Stack ===

% @constraint Zero base for stack op.
soft(stack_zero,V) :- stack(V,zero).

% @constraint Normalize between groupbys as stack op.
soft(stack_normalize,V) :- stack(V,normalize).

% === Task - marktype correlations ===

% @constraint Point mark for value tasks.
soft(value_point,V) :- task(V,value), mark(V,point).

% @constraint Bar mark for value tasks.
soft(value_bar,V) :- task(V,value), mark(V,bar).

% @constraint Line mark for value tasks.
soft(value_line,V) :- task(V,value), mark(V,line).

% @constraint Area mark for value tasks.
soft(value_area,V) :- task(V,value), mark(V,area).

% @constraint Text mark for value tasks.
soft(value_text,V) :- task(V,value), mark(V,text).

% @constraint Tick mark for value tasks.
soft(value_tick,V) :- task(V,value), mark(V,tick).
% @end

% @constraint Rect mark for value tasks.
soft(value_rect,V) :- task(V,value), mark(V,rect).

% @constraint Point mark for summary tasks.
soft(summary_point,V) :- task(V,summary), mark(V,point).

% @constraint Bar mark for summary tasks.
soft(summary_bar,V) :- task(V,summary), mark(V,bar).

% @constraint Line mark for summary tasks.
soft(summary_line,V) :- task(V,summary), mark(V,line).

% @constraint Area mark for summary tasks.
soft(summary_area,V) :- task(V,summary), mark(V,area).

% @constraint Text mark for summary tasks.
soft(summary_text,V) :- task(V,summary), mark(V,text).

% @constraint Tick mark for summary tasks.
soft(summary_tick,V) :- task(V,summary), mark(V,tick).

% @constraint Rect mark for summary tasks.
soft(summary_rect,V) :- task(V,summary), mark(V,rect).

% === Task - channel correlations ===

% @constraint Continuous x for value tasks.
soft(value_continuous_x,V,E) :- task(V,value), channel(V,E,x), continuous(V,E), enc_interesting(V,E).

% @constraint Continuous y for value tasks.
soft(value_continuous_y,V,E) :- task(V,value), channel(V,E,y), continuous(V,E), enc_interesting(V,E).

% @constraint Continuous color for value tasks.
soft(value_continuous_color,V,E) :- task(V,value), channel(V,E,color), continuous(V,E), enc_interesting(V,E).

% @constraint Continuous size for value tasks.
soft(value_continuous_size,V,E) :- task(V,value), channel(V,E,size), continuous(V,E), enc_interesting(V,E).

% @constraint Continuous text for value tasks.
soft(value_continuous_text,V,E) :- task(V,value), channel(V,E,text), continuous(V,E), enc_interesting(V,E).

% @constraint Discrete x for value tasks.
soft(value_discrete_x,V,E) :- task(V,value), channel(V,E,x), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete y for value tasks.
soft(value_discrete_y,V,E) :- task(V,value), channel(V,E,y), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete color for value tasks.
soft(value_discrete_color,V,E) :- task(V,value), channel(V,E,color), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete shape for value tasks.
soft(value_discrete_shape,V,E) :- task(V,value), channel(V,E,shape), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete size for value tasks.
soft(value_discrete_size,V,E) :- task(V,value), channel(V,E,size), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete text for value tasks.
soft(value_discrete_text,V,E) :- task(V,value), channel(V,E,text), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete row for value tasks.
soft(value_discrete_row,V,E) :- task(V,value), channel(V,E,row), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete column for value tasks.
soft(value_discrete_column,E) :- task(V,value), channel(V,E,column), discrete(V,E), enc_interesting(V,E).

% @constraint Continuous x for summary tasks.
soft(summary_continuous_x,E) :- task(V,summary), channel(V,E,x), continuous(V,E), enc_interesting(V,E).

% @constraint Continuous y for summary tasks.
soft(summary_continuous_y,E) :- task(V,summary), channel(V,E,y), continuous(V,E), enc_interesting(V,E).

% @constraint Continuous color for summary tasks.
soft(summary_continuous_color,E) :- task(V,summary), channel(V,E,color), continuous(V,E), enc_interesting(V,E).

% @constraint Continuous size for summary tasks.
soft(summary_continuous_size,E) :- task(V,summary), channel(V,E,size), continuous(V,E), enc_interesting(V,E).

% @constraint Continuous text for summary tasks.
soft(summary_continuous_text,E) :- task(V,summary), channel(V,E,text), continuous(V,E), enc_interesting(V,E).

% @constraint Discrete x for summary tasks.
soft(summary_discrete_x,E) :- task(V,summary), channel(V,E,x), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete y for summary tasks.
soft(summary_discrete_y,E) :- task(V,summary), channel(V,E,y), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete color for summary tasks.
soft(summary_discrete_color,E) :- task(V,summary), channel(V,E,color), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete shape for summary tasks.
soft(summary_discrete_shape,E) :- task(V,summary), channel(V,E,shape), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete size for summary tasks.
soft(summary_discrete_size,E) :- task(V,summary), channel(V,E,size), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete text for summary tasks.
soft(summary_discrete_text,E) :- task(V,summary), channel(V,E,text), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete row for summary tasks.
soft(summary_discrete_row,E) :- task(V,summary), channel(V,E,row), discrete(V,E), enc_interesting(V,E).

% @constraint Discrete column for summary tasks.
soft(summary_discrete_column,E) :- task(V,summary), channel(V,E,column), discrete(V,E), enc_interesting(V,E).