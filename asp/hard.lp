:- visualization(V), hard(_,V).
:- visualization(V), hard(_,V,_).
:- visualization(V), hard(_,V,_,_).

% ====== Expressiveness and Well-Formedness Constraints ======

% === Within Encodings ===

% @constraint Primitive type has to support data type.
hard(enc_type_valid,V,E,F) :- type(V,E,quantitative), field(V,E,F), fieldtype(F,(string;boolean)).
hard(enc_type_valid,V,E,F) :- type(V,E,temporal), field(V,E,F), not fieldtype(F,datetime).

% @constraint Can only bin quantitative or ordinal.
hard(bin_q_o,V,E,T) :- type(V,E,T), bin(V,E,_), T != quantitative, T != ordinal.

% @constraint Can only use log with quantitative.
hard(log_q,V,E) :- log(V,E), not type(V,E,quantitative).

% @constraint Can only use zero with quantitative.
hard(zero_q,V,E) :- zero(V,E), not type(V,E,quantitative).

% @constraint Cannot use log scale with discrete (which includes binned).
hard(log_discrete,V,E) :- log(V,E), discrete(V,E).

% @constraint Cannot use log and zero together.
hard(log_zero,V,E) :- log(V,E), zero(V,E).

% @constraint Cannot use log if the data is negative or zero.
hard(log_non_positive,V,E,F) :- log(V,E), field(V,E,F), extent(F,MIN,_), MIN <= 0.

% @constraint Cannot bin and aggregate.
hard(bin_and_aggregate,V,E) :- aggregate(V,E,_), bin(V,E,_).

% @constraint Oridnal only supports min, max, and median.
hard(aggregate_o_valid,V,E,A) :- aggregate(V,E,A), type(V,E,ordinal), A != min, A != max, A != median.

% @constraint Temporal only supports min and max.
hard(aggregate_t_valid,V,E,A) :- aggregate(V,E,A), type(V,E,temporal), A != min, A != max.

% @constraint Cannot aggregate nominal.
hard(aggregate_nominal,V,E) :- aggregate(V,E,_), type(V,E,nominal).

% @constraint Detail cannot be aggregated.
hard(aggregate_detail,V,E) :- channel(V,E,detail), aggregate(V,E,_).

% @constraint Count has to be quantitative and not use a field.
hard(count_q_without_field,V,E) :- aggregate(V,E,count), field(V,E,_).
hard(count_q_without_field,V,E) :- aggregate(V,E,count), not type(V,E,quantitative).

% @constraint Shape requires discrete and not ordered (nominal). Using ordinal would't make a difference in Vega-Lite.
hard(shape_discrete_non_ordered,V,E) :- channel(V,E,shape), not type(V,E,nominal).

% @constraint Detail requires nominal.
hard(detail_non_ordered,V,E) :- channel(V,E,detail), not type(V,E,nominal).

% @constraint Size implies order so nominal is misleading.
hard(size_nominal,V,E) :- channel(V,E,size), type(V,E,nominal).

% @constraint Do not use size when data is negative as size implies that data is positive.
hard(size_negative,V,E) :- channel(V,E,size), enc_extent(V,E,MIN,MAX), MIN < 0, MAX > 0.

% === Across encodings and between encodings and marks ===

% @constraint Cannot use single channels twice.
hard(repeat_channel,V,C) :- visualization(V), single_channel(C), 2 { channel(V,_,C) }.

% @constraint There has to be at least one encoding. Otherwise, the visualization doesn't show anything.
hard(no_encodings,V) :- visualization(V), not encoding(V,_).

% @constraint Row and column require discrete.
hard(row_or_column_c,V) :- channel_continuous(V,(row;column)).

% @constraint Don't use row without y. Just using y is simpler.
hard(row_no_y,V) :- channel(V,_,row), not channel(V,_,y).

% @constraint Don't use column without x. Just using x is simpler.
hard(column_no_x,V) :- channel(V,_,column), not channel(V,_,x).

% @constraint All encodings (if they have a channel) require field except if we have a count aggregate.
hard(encoding_no_field_and_not_count,V,E) :- not field(V,E,_), not aggregate(V,E,count), encoding(V,E).

% @constraint Count should not have a field. Having a field doesn't make a difference.
hard(count_with_field,V,E) :- aggregate(V,E,count), field(V,E,_).

% @constraint Text mark requires text channel.
hard(text_mark_without_text_channel,V) :- mark(V,text), not channel(V,_,text).

% @constraint Text channel requires text mark.
hard(text_channel_without_text_mark,V) :- channel(V,E,text), not mark(V,text).

% @constraint Point, tick, and bar require x or y channel.
hard(point_tick_bar_without_x_or_y,V) :- mark(V,(point;tick;bar)), not channel(V,_,x), not channel(V,_,y).

% @constraint Line and area require x and y channel.
hard(line_area_without_x_y,V) :- mark(V,(line;area)), not channel(V,_,(x;y)).

% @constraint Line and area cannot have two discrete.
hard(line_area_with_discrete,V) :- mark(V,(line;area)), channel_discrete(V,x), channel_discrete(V,y).

% @constraint Bar and tick cannot have both x and y continuous.
hard(bar_tick_continuous_x_y,V) :- mark(V,(bar;tick)), channel_continuous(V,x), channel_continuous(V,y).

% @constraint Bar, tick, line, area require some continuous variable on x or y.
hard(bar_tick_area_line_without_continuous_x_y,V) :- mark(V,(bar;tick;area;line)), not channel_continuous(V,x), not channel_continuous(V,y).

% @constraint Bar and area mark requires scale of continuous to start at zero.
hard(bar_area_without_zero,V) :- mark(V,(bar;area)), channel(V,E,x), orientation(V,horizontal), not zero(V,E).
hard(bar_area_without_zero,V) :- mark(V,(bar;area)), channel(V,E,y), orientation(V,vertical), not zero(V,E).

% @constraint Shape channel requires point mark.
hard(shape_without_point,V) :- channel(V,_,shape), not mark(V,point).

% @constraint Size only works with some marks. Vega-Lite can also size lines, and ticks but that would violate best practices.
hard(size_without_point_text,V) :-  channel(V,_,size), not mark(V,point), not mark(V,text).

% @constraint Detail requires aggregation. Detail adds a field to the group by. Detail could also be used to add information to tooltips. We may remove this later.
hard(detail_without_agg,V) :- channel(V,_,detail), not aggregate(V,_,_).

% @constraint Do not use log for bar or area mark as they are often misleading. We may remove this rule in the future.
hard(area_bar_with_log,V) :- mark(V,(bar;area)), channel(V,E,(x;y)), log(V,E).

% @constraint Rect mark needs discrete x and y.
hard(rect_without_d_d,V) :- mark(V,rect), not is_d_d(V).

% @constraint Don't use the same field on x and y.
hard(same_field_x_and_y,V) :- visualization(V), { field(V,E,F) : channel(V,E,x); field(V,E,F) : channel(V,E,y) } >= 2, field(F).

% @constraint Don't use count on x and y.
hard(count_on_x_and_y,V):- channel(V,EX,x), channel(V,EY,y), aggregate(V,EX,count), aggregate(V,EY,count).

% @constraint If we use aggregation, then all continuous fields need to be aggeragted.
hard(aggregate_not_all_continuous,V):- aggregate(V,E,_), continuous(V,E), not aggregate(V,E,_).

% @constraint Don't use count twice.
hard(count_twice) :- visualization(V), { aggregate(V,_,count) } = 2.

% === Global properties ===

% @constraint Bars and area cannot overlap.
hard(bar_area_overlap,V) :- mark(V,(bar;area)), overlap(V).

% @constraint Rects shouldn't overlap. They are used for dioscrete heatmaps.
hard(rect_overlap,V) :- mark(V,rect), overlap(V).

% == Stacking ==

% @constraint Only use stacking for bar and area.
hard(stack_without_bar_area,V) :- stack(V,_), not mark(V,bar), not mark(V,area).

% @constraint Don't stack if aggregation is not summative (summative are count, sum, distinct, valid, missing).
hard(stack_without_summative_agg,V,E,A) :- aggregate(V,E,A), stack(V,E,_), not summative_aggregate_op(A).

% @constraint Need to stack if we use bar, area with discrete color.
hard(no_stack_with_bar_area_discrete_color,V,E) :- mark(V,(bar;area)), encoding(V,E), channel(V,E,color), discrete(V,E), not stack(V,_).

% @constraint Can only use stack if we also use discrete color, or detail.
hard(stack_without_discrete_color_or_detail,V) :- stack(V,_), not channel_discrete(V,color), { channel(V,E,detail) } = 0.

% @constraint If we use stack and detail, we also have to use quantitative color.
hard(stack_detail_without_q_color,V) :- stack(V,_), channel(V,_,detail), not channel(V,_,color).
hard(stack_detail_without_q_color,V,E) :- stack(V,_), channel(V,_,detail), channel(V,E,color), not aggregate(V,E,_).

% @constraint Stack can only be on continuous.
hard(stack_discrete,V,E) :- encoding(V,E), stack(V,E,_), discrete(V,E).

% @constraint Stack can only be on x or y.
hard(stack_without_x_y,V,E) :- encoding(V,E), stack(V,E,_), not channel(V,E,x), not channel(V,E,y).

% @constraint Cannot use non positional continuous with stack unless it's aggregated.
hard(stack_with_non_positional_non_agg,V,E,C) :- stack(V,_), encoding(V,E), non_positional(C), channel(V,E,C), not aggregate(V,E,_), continuous(V,E).

% @constraint Vega-Lite currently supports 8 shapes.
hard(shape_with_cardinality_gt_eight,V,E,C) :- channel(V,E,shape), enc_cardinality(V,E,C), C > 8.

% @constraint At most 20 categorical colors.
hard(color_with_cardinality_gt_twenty,V,E,C) :- channel(V,E,color), discrete(V,E), enc_cardinality(V,E,C), C > 20.

% === Type checks ===

% @constraint Check mark.
hard(invalid_mark,V,M) :- mark(V,M), not marktype(M).

% @constraint Check types of encoding properties.
hard(invalid_channel,V,C) :- channel(V,_,C), not channel(C).
hard(invalid_field,V,F) :- field(V,_,F), not field(F).
hard(invalid_type,V,T) :- type(V,_,T), not type(T).
hard(invalid_agg,V,A) :- aggregate(V,_,A), not aggregate_op(A).
hard(invalid_bin,V,B) :- bin(V,_,B), not B >= 0.  % @constraint Bin has to be a natural number.

% @constraint Fieldtype has to be primitive type.
hard(invalid_fieldtype,V,T) :- visualization(V), fieldtype(_,T), not primitive_type(T).

% @constraint Task has to be one of the tasks.
hard(invalid_task,V,T) :- visualization(V), task(V,T), not tasks(T).

% @constraint Num_rows has to be larger than 0.
hard(invalid_num_rows,V,S) :- visualization(V), num_rows(S), S < 0.

% @constraint Cardinality has to be larger than 0.
hard(invalid_cardinality,V,C) :- visualization(V), cardinality(_,C), C < 0.

% @constraint Entropy has to be positive.
hard(invalid_entropy,V,E) :- visualization(V), entropy(_,E), E < 0.

% @constraint Extent only allowed for numbers (for now).
hard(invalid_extent_non_number,V,F) :- visualization(V), extent(F,_,_), not fieldtype(F,number).

% @constraint Order has to be correct.
hard(invalid_extent_order,V,MIN,MAX):- visualization(V), extent(_,MIN,MAX), MIN > MAX.

% @constraint The name of a field cannot be the name of an encoding. This is to prevent errors coming from the shortcuts in define.lp.
hard(encoding_field_same_name,V,N) :- visualization(V), encoding(V,N), field(N).