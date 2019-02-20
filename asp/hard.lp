% ====== Expressiveness and Well-Formedness Constraints ======

% === Within Encodings ===

% @constraint Primitive type has to support data type.
hard(enc_type_valid,E,F) :- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).
hard(enc_type_valid,E,F) :- type(E,temporal), field(E,F), not fieldtype(F,datetime).

% @constraint Can only bin quantitative or ordinal.
hard(bin_q_o,E,T) :- type(E,T), bin(E,_), T != quantitative, T != ordinal.

% @constraint Can only use log with quantitative.
hard(log_q,E) :- log(E), not type(E,quantitative).

% @constraint Can only use zero with quantitative.
hard(zero_q,E) :- zero(E), not type(E,quantitative).

% @constraint Cannot use log scale with discrete (which includes binned).
hard(log_discrete,E) :- log(E), discrete(E).

% @constraint Cannot use log and zero together.
hard(log_zero,E) :- log(E), zero(E).

% @constraint Cannot use log if the data is negative or zero.
hard(log_non_positive,E,F) :- log(E), field(E,F), extent(F,MIN,_), MIN <= 0.

% @constraint Cannot bin and aggregate.
hard(bin_and_aggregate,E) :- bin(E,_), aggregate(E,_).

% @constraint Oridnal only supports min, max, and median.
hard(aggregate_o_valid,E,A) :- type(E,ordinal), aggregate(E,A), A != min, A != max, A != median.

% @constraint Temporal only supports min and max.
hard(aggregate_t_valid,E,A) :- type(E,temporal), aggregate(E,A), A != min, A != max.

% @constraint Cannot aggregate nominal.
hard(aggregate_nominal,E) :- aggregate(E,_), type(E,nominal).

% @constraint Detail cannot be aggregated.
hard(aggregate_detail,E) :- channel(E,detail), aggregate(E,_).

% @constraint Count has to be quantitative and not use a field.
hard(count_q_without_field,E) :- aggregate(E,count), field(E,_).
hard(count_q_without_field,E) :- aggregate(E,count), not type(E,quantitative).

% @constraint Shape requires discrete and not ordered (nominal). Using ordinal would't make a difference in Vega-Lite.
hard(shape_discrete_non_ordered,E) :- channel(E,shape), not type(E,nominal).

% @constraint Detail requires nominal.
hard(detail_non_ordered,E) :- channel(E,detail), not type(E,nominal).

% @constraint Size implies order so nominal is misleading.
hard(size_nominal) :- channel(E,size), type(E,nominal).

% @constraint Do not use size when data is negative as size implies that data is positive.
hard(size_negative,E) :- channel(E,size), enc_extent(E,MIN,MAX), MIN < 0, MAX > 0.

% === Across encodings and between encodings and marks ===

% @constraint Cannot use single channels twice.
hard(repeat_channel,C):- single_channel(C), 2 { channel(_,C) }.

% @constraint There has to be at least one encoding. Otherwise, the visualization doesn't show anything.
hard(no_encodings) :- not encoding(_).

% @constraint Row and column require discrete.
hard(row_or_column_c) :- channel_continuous(row;column).

% @constraint Don't use row without y. Just using y is simpler.
hard(row_no_y) :- channel(_,row), not channel(_,y).

% @constraint Don't use column without x. Just using x is simpler.
hard(column_no_x) :- channel(_,column), not channel(_,x).

% @constraint All encodings (if they have a channel) require field except if we have a count aggregate.
hard(encoding_no_field_and_not_count,E) :- not field(E,_), not aggregate(E,count), encoding(E).

% @constraint Count should not have a field. Having a field doesn't make a difference.
hard(count_with_field,E) :- aggregate(E,count), field(E,_).

% @constraint Text mark requires text channel.
hard(text_mark_without_text_channel) :- mark(text), not channel(_,text).

% @constraint Text channel requires text mark.
hard(text_channel_without_text_mark) :- channel(_,text), not mark(text).

% @constraint Point, tick, and bar require x or y channel.
hard(point_tick_bar_without_x_or_y) :- mark(point;tick;bar), not channel(_,x), not channel(_,y).

% @constraint Line and area require x and y channel.
hard(line_area_without_x_y) :- mark(line;area), not channel(_,(x;y)).

% @constraint Line and area cannot have two discrete.
hard(line_area_with_discrete) :- mark(line;area), channel_discrete(x), channel_discrete(y).

% @constraint Bar and tick cannot have both x and y continuous.
hard(bar_tick_continuous_x_y) :- mark(bar;tick), channel_continuous(x), channel_continuous(y).

% @constraint Bar, tick, line, area require some continuous variable on x or y.
hard(bar_tick_area_line_without_continuous_x_y) :- mark(bar;tick;area;line), not channel_continuous(x), not channel_continuous(y).

% @constraint Bar and area mark requires scale of continuous to start at zero.
hard(bar_area_without_zero) :- mark(bar;area), channel(E,x), orientation(horizontal), not zero(E).
hard(bar_area_without_zero) :- mark(bar;area), channel(E,y), orientation(vertical), not zero(E).

% @constraint Shape channel requires point mark.
hard(shape_without_point) :- channel(_,shape), not mark(point).

% @constraint Size only works with some marks. Vega-Lite can also size lines, and ticks but that would violate best practices.
hard(size_without_point_text) :- channel(_,size), not mark(point), not mark(text).

% @constraint Detail requires aggregation. Detail adds a field to the group by. Detail could also be used to add information to tooltips. We may remove this later.
hard(detail_without_agg) :- channel(_,detail), not aggregate(_,_).

% @constraint Do not use log for bar or area mark as they are often misleading. We may remove this rule in the future.
hard(area_bar_with_log) :- mark(bar;area), log(E), channel(E,(x;y)).

% @constraint Rect mark needs discrete x and y.
hard(rect_without_d_d) :- mark(rect), not is_d_d.

% @constraint Don't use the same field on x and y.
hard(same_field_x_and_y) :- { field(E,F) : channel(E,x); field(E,F) : channel(E,y) } >= 2, field(F).

% @constraint Don't use count on x and y.
hard(count_on_x_and_y):- channel(EX,x), channel(EY,y), aggregate(EX,count), aggregate(EY,count).

% @constraint If we use aggregation, then all continuous fields need to be aggeragted.
hard(aggregate_not_all_continuous):- aggregate(_,_), continuous(E), not aggregate(E,_).

% @constraint Don't use count twice.
hard(count_twice) :- { aggregate(_,count) } = 2.

% === Global properties ===

% @constraint Bars and area cannot overlap.
hard(bar_area_overlap) :- mark(bar;area), overlap.

% @constraint Rects shouldn't overlap. They are used for dioscrete heatmaps.
hard(rect_overlap) :- mark(rect), overlap.

% == Stacking ==

% @constraint Only use stacking for bar and area.
hard(stack_without_bar_area) :- stack(_), not mark(bar), not mark(area).

% @constraint Don't stack if aggregation is not summative (summative are count, sum, distinct, valid, missing).
hard(stack_without_summative_agg,E,A) :- stack(E,_), aggregate(E,A), not summative_aggregate_op(A).

% @constraint Need to stack if we use bar, area with discrete color.
hard(no_stack_with_bar_area_discrete_color,E) :- mark(bar;area), channel(E,color), discrete(E), not stack(_).

% @constraint Can only use stack if we also use discrete color, or detail.
hard(stack_without_discrete_color_or_detail) :- stack(_), not channel_discrete(color), not channel(_,detail).

% @constraint If we use stack and detail, we also have to use quantitative color.
hard(stack_detail_without_q_color) :- stack(_), channel(_,detail), not channel(_,color).
hard(stack_detail_without_q_color,E) :- stack(_), channel(_,detail), channel(E,color), not aggregate(E,_).

% @constraint Stack can only be on continuous.
hard(stack_discrete,E) :- stack(E,_), discrete(E).

% @constraint Stack can only be on x or y.
hard(stack_without_x_y,E) :- stack(E,_), not channel(E,x), not channel(E,y).

% @constraint Cannot use non positional continuous with stack unless it's aggregated.
hard(stack_with_non_positional_non_agg,E,C) :- stack(_), non_positional(C), channel(E,C), not aggregate(E,_), continuous(E).

% @constraint Vega-Lite currently supports 8 shapes.
hard(shape_with_cardinality_gt_eight,E,C) :- channel(E,shape), enc_cardinality(E,C), C > 8.

% @constraint At most 20 categorical colors.
hard(color_with_cardinality_gt_twenty,E,C) :- channel(E,color), discrete(E), enc_cardinality(E,C), C > 20.

% === Type checks ===

% @constraint Check mark.
hard(invalid_mark,M) :- mark(M), not marktype(M).

% @constraint Check types of encoding properties.
hard(invalid_channel,C) :- channel(_,C), not channel(C).
hard(invalid_field,F) :- field(_,F), not field(F).
hard(invalid_type,T) :- type(_,T), not type(T).
hard(invalid_agg,A) :- aggregate(_,A), not aggregate_op(A).
hard(invalid_bin,B) :- bin(_,B), not B >= 0.  % @constraint Bin has to be a natural number.

% @constraint Fieldtype has to be primitive type.
hard(invalid_fieldtype,T) :- fieldtype(_,T), not primitive_type(T).

% @constraint Task has to be one of the tasks.
hard(invalid_task,T) :- task(T), not tasks(T).

% @constraint Num_rows has to be larger than 0.
hard(invalid_num_rows,S) :- num_rows(S), S < 0.

% @constraint Cardinality has to be larger than 0.
hard(invalid_cardinality,C) :- cardinality(_,C), C < 0.

% @constraint Entropy has to be positive.
hard(invalid_entropy,E) :- entropy(_,E), E < 0.

% @constraint Extent only allowed for numbers (for now).
hard(invalid_extent_non_number,F) :- extent(F,_,_), not fieldtype(F,number).

% @constraint Order has to be correct.
hard(invalid_extent_order,MIN,MAX):- extent(_,MIN,MAX), MIN > MAX.

% @constraint The name of a field cannot be the name of an encoding. This is to prevent errors coming from the shortcuts in define.lp.
hard(encoding_field_same_name,N) :- encoding(N), field(N).
