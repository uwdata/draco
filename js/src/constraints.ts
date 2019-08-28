// GENERATED WITH concat_lp.sh. DO NOT MODIFY.

export const TOPK_LUA: string = `#script(lua)

function main(prg)
    local count = tonumber(prg.configuration.solve.models)
    local backend = prg:backend()

    local observer = {
        minimize_literals = {}
    }
    function observer:minimize (priority, literals)
        self.minimize_literals = literals
    end

    prg:register_observer(observer)

    prg:ground({{"base", {}}}, self)

    while count > 0 do
        local cost = 0

        prg.configuration.solve.models = count
        local it = prg:solve{yield=true}
        local ret, err = pcall(function()
            if it:get().unsatisfiable then
                count = 0
                return
            end

            for m in it:iter() do
                if m.optimality_proven then
                    cost = m.cost[1]
                    count = count-1
                end
            end
        end)
        it:close()
        if not ret then
            error(err)
        end

        if count > 0 then
            local aux = backend:add_atom()
            backend:add_weight_rule{{aux}, cost+1, observer.minimize_literals}
            backend:add_rule{{aux}, {-aux}}
        end
    end
end
#end.

`;

export const DEFINE: string = `% ====== Definitions ======

% Types of marks to encode data.
marktype(point;bar;line;area;text;tick;rect).
% High level data types: quantitative, ordinal, nominal, temporal.
type(quantitative;ordinal;nominal;temporal).
% Basic types of the data.
primitive_type(string;number;boolean;datetime).
% Supported aggregation functions.
aggregate_op(count;mean;median;min;max;stdev;sum).
summative_aggregate_op(count;sum).
% Numbers of bins that can be recommended; any natural number is allowed.
binning(10;25;200).

% Encoding channels.
single_channel(x;y;color;size;shape;text;row;column).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).
non_positional(color;size;shape;text;detail).

% Possible tasks.
tasks(value;summary).

% Possible stackings.
stacking(zero;normalize).

% ====== Helpers ======

discrete(E) :- type(E,(nominal;ordinal)).
discrete(E) :- bin(E,_).
continuous(E) :- encoding(E), not discrete(E).

channel_discrete(C) :- discrete(E), channel(E,C).
channel_continuous(C) :- continuous(E), channel(E,C).

ordered(E) :- type(E,(ordinal;quantitative)).

% Fields
field(F) :- fieldtype(F,_).

% Stacking is applied to the continuous x or y.
stack(EC,S) :- channel(EC,(x;y)), channel(ED,(x;y)), continuous(EC), discrete(ED), stack(S).
% X and y are continuous.
stack(E,S) :- channel_continuous(x), channel(E,y), continuous(E), stack(S).

stack(S) :- stack(_,S).

% Data properties
enc_cardinality(E,C) :- field(E,F), cardinality(F,C).
enc_entropy(E,EN) :- field(E,F), entropy(F,EN).
enc_interesting(E) :- field(E,F), interesting(F).
enc_extent(E,MIN,MAX) :- field(E,F), extent(F,MIN,MAX).

% Cardinality of discrete field. A binned field has the cadinality of its field.
discrete_cardinality(E,CE) :- discrete(E), enc_cardinality(E,CE), channel(E,C), not bin(E,_).
discrete_cardinality(E,CB) :- channel(E,C), bin(E,CB).

% Define a fake soft/2 for all soft/1.
soft(F,_placeholder) :- soft(F).

% Silence warnings about properties never appearing in head.
entropy(0,0) :- #false.
interesting(0) :- #false.
extent(0,0,0) :- #false.
soft(0) :- #false.
task(value) :- #false.
task(summary) :- #false.
data(0) :- #false.

% == Chart Types ==

% Continuous by continuous.
is_c_c :- channel_continuous(x), channel_continuous(y).

% Continuous by discrete (or continuous only).
is_c_d :- channel_continuous(x), not channel_continuous(y).
is_c_d :- channel_continuous(y), not channel_continuous(x).

% Discrete by discrete.
is_d_d :- channel_discrete(x), channel_discrete(y).

% == Overlap ==

% The continuous variable is a measure (it is aggregated) and all other channels are .aggregated, or we use stack -> no overlap
non_pos_unaggregated :- channel(E,C), non_positional(C), not aggregate(E,_).
no_overlap :- is_c_d, continuous(E), channel(E,(x;y)), aggregate(E,_), not non_pos_unaggregated.
no_overlap :- is_c_d, stack(_).

% the size of the discrete positional encoding
discrete_size(S) :- is_c_d, x_y_cardinality(_,S).
discrete_size(1) :- is_c_d, channel_continuous(x), not channel(_,y).
discrete_size(1) :- is_c_d, channel_continuous(y), not channel(_,x).

% Data size is as small as discrete dimension -> no overlap.
no_overlap :- is_c_d, num_rows(S), discrete_size(S).

% We definitely overlap if the data size > discrete size.
overlap :- is_c_d, not no_overlap, num_rows(S1), discrete_size(S2), S1 > S2.

% helpers to go from quadratic to linear number of grounding
x_y_cardinality(x,S) :- channel(E,x), discrete_cardinality(E,S).
x_y_cardinality(y,S) :- channel(E,y), discrete_cardinality(E,S).

% No overlap if all other dimensions are aggregated.
discrete_size(S) :- is_d_d, x_y_cardinality(x,SX), x_y_cardinality(y,SY), S = SX*SY.
no_overlap :- is_d_d, not non_pos_unaggregated.
no_overlap :- is_d_d, num_rows(S1), discrete_size(S2), S1 <= S2.  % This cannot guarantee no overlap.

% We can guarantee overlap using this rule unless we are using row / column.
row_col :- channel(_,(row;column)).
overlap :- is_d_d, channel(E,C), not row_col, not no_overlap, num_rows(S1), discrete_size(S2), S1 > S2.

% == Orientation ==

% Orientation tells us which one is the dependent and independent variable.

orientation(vertical) :- mark(bar;tick;area;line), channel_discrete(x).
orientation(vertical) :- mark(area;line), channel_continuous(x), channel_continuous(y).

orientation(horizontal) :- mark(bar;tick;area;line), channel_discrete(y).

`;

export const GENERATE: string = `% ====== Generators ======

% encodings

% maximum number for each multi channel encoding
#const max_extra_encs = 5.

obj_id(1..max_extra_encs).

{ encoding(E): obj_id(E) }.

:- not encoding(ID), encoding(ID-1), obj_id(ID), obj_id(ID-1).

% properties of encodings

% channel and type have to be present
{ channel(E,C): channel(C) } = 1 :- encoding(E).
{ type(E,T): type(T) } = 1 :- encoding(E).

% other properties that are not required
0 { field(E,F): field(F) } 1 :- encoding(E).
0 { aggregate(E,A): aggregate_op(A) } 1 :- encoding(E).
0 { bin(E,B): binning(B) } 1 :- encoding(E).
0 { zero(E) } 1 :- encoding(E).
0 { log(E) } 1 :- encoding(E).

% pick one mark type

{ mark(M) : marktype(M) } = 1.

% stacking

0 { stack(S): stacking(S) } 1.

`;

export const HARD: string = `% ====== Expressiveness and Well-Formedness Constraints ======

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

`;

export const HARD_INTEGRITY: string = `:- hard(_).
:- hard(_,_).
:- hard(_,_,_).

`;

export const SOFT: string = `% After adding a soft constraint to this file, make sure to update 'weights.lp' and run 'process_softs.py'..

% ====== Preferences ======

% @constraint Prefer to use raw (no aggregate).
soft(aggregate,E) :- aggregate(E,_).

% @constraint Prefer to not bin.
soft(bin,E) :- bin(E,_).

% @constraint Prefer binning with at most 12 buckets.
soft(bin_high,E) :- bin(E,B), B > 12.

% @constraint Prefer binning with more than 7 buckets.
soft(bin_low,E) :- bin(E,B), B <= 7.

% @constraint Prefer to use fewer encodings.
soft(encoding,E) :- encoding(E).

% @constraint Prefer to use fewer encodings with fields (count does not have a field).
soft(encoding_field,E) :- encoding(E), field(E,_).

% @constraint Prefer not to use the same field twice.
soft(same_field_2,F) :- field(F), { field(_,F) } = 2.

% @constraint Prefer not to use the same field three or more times.
% @weight {16}
soft(same_field_gte3,F) :- field(F), { field(_,F) } >= 3.
% @end

% @constraint Prefer not to use count more than once.
soft(count_twice) :- { aggregate(_,count) } = 2.

% @constraint Shape channel should not have too high cardinality.
soft(shape_cardinality,E) :- channel(E,shape), discrete_cardinality(E,C), C > 5.

% @constraint Numbers should not be nominal.
soft(number_nominal,E) :- type(E,nominal), field(E,F), fieldtype(F,number).

% @constraint Binned quantitative field should not have too low cardinality.
soft(bin_cardinality,E) :- type(E,quantitative), bin(E,_), enc_cardinality(E,C), C < 15.

% @constraint Prefer quantitative for bin.
soft(quant_bin,E) :- bin(E,_), not type(E,quantitative).

% @constraint Plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field.
soft(only_discrete) :- not continuous(_).

% @constraint Prefer not to use multiple non-positional encoding channels.
soft(multiple_non_pos) :- {channel(_,C): non_positional(C)} > 1.

% @constraint Prefer not to use non-positional channels until all positional channels are used.
soft(non_positional_pref) :- channel(_,C), non_positional(C), not channel(_,(x;y)).

% @constraint Aggregate plots should not use raw continuous as group by.
soft(aggregate_group_by_raw,E) :- aggregate(_,_), continuous(E), not aggregate(E,_).

% @constraint Aggregate should also have a discrete encoding to group by.
soft(agg_dim) :- aggregate(_,_), not discrete(_).

% @constraint Prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion.
soft(x_y_raw,E) :- channel(EX,x), discrete(EX), channel(EY,y), discrete(EY), not aggregate(E,_), continuous(E).

% @constraint Prefer not to use log scale.
soft(log,E) :- log(E).

% @constraint Prefer to include zero for continuous (binned doesn't need zero).
soft(zero,E) :- continuous(E), not zero(E).

% @constraint Prefer zero size (even when binned).
soft(zero_size) :- channel(E,size), not zero(E).

% @constraint Prefer zero positional.
soft(zero_positional) :- continuous(E), channel(E,(x;y)), not zero(E).

% @constraint Prefer not to use zero when the difference between min and max is larger than distance to 0.
soft(zero_skew) :- enc_extent(E,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX, zero(E).

% @constraint Do not include zero when the range of data includes zero.
soft(includes_zero) :- zero(E), extent(E,MIN,MAX), MIN < 0, MAX > 0.

% @constraint Prefer to use only x instead of only y.
soft(only_x) :- channel(_,y), not channel(_,x).

% @constraint Chart orientation for bar and tick (with and without bin). Binned fields have short labels if they are quantitative while otherwise labels can be long.
soft(orientation_binned) :- bin(E,_), type(E,quantitative), not channel(E,x).

% @constraint Prefer not to use ordinal for fields with high cardinality.
soft(high_cardinality_ordinal,E) :- type(E,ordinal), discrete_cardinality(E,C), C > 30.

% @constraint Prefer not to use nominal for fields with high cardinality.
soft(high_cardinality_nominal,E) :- type(E,nominal), enc_cardinality(E,C), C > 12.

% @constraint Prefer not to use high cardinality nominal for color.
soft(high_cardinality_nominal_color,E) :- type(E,nominal), channel(E,color), enc_cardinality(E,C), C > 10.

% @constraint Avoid high cardinality on x or column as it causes horizontal scrolling.
soft(horizontal_scrolling,E) :- channel(E,x), discrete_cardinality(E,C), C > 50.
soft(horizontal_scrolling,E) :- channel(E,columm), discrete_cardinality(E,C), C > 5.

% @constraint Prefer to use temporal type with dates.
soft(temporal_date,E) :- field(E,F), fieldtype(F,datetime), not type(E,temporal).

% @constraint Prefer quantitative for numbers with high cardinality.
soft(quantitative_numbers) :- field(E,F), fieldtype(F,number), cardinality(F,C), C > 20, not bin(E,_), not type(E,quantitative).

% @constraint Overplotting. Prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overplot.
soft(position_entropy,E) :- channel(E,(x;y)), continuous(E), enc_cardinality(E,C), C > 100, enc_entropy(E,EN), EN <= 12, not aggregate(E,_).

% @constraint Prefer not to use size when the cardinality is large on x or y.
soft(high_cardinality_size,E) :- continuous(E), channel(_,size), enc_cardinality(E,C), C > 100, channel(E,(x;y)).

% @constraint Prefer not to aggregate for value tasks.
soft(value_agg) :- task(value), aggregate(_,_).

% @constraint Prefer not to use row and column for summary tasks as it makes it difficult to compare.
soft(facet_summary,E) :- task(summary), channel(E,row).

% @constraint Positional interactions as suggested by Kim et al.
soft(x_row) :- channel(_,x), channel(_,row).

% @constraint Positional interactions as suggested by Kim et al.
soft(y_row) :- channel(_,y), channel(_,row).

% @constraint Positional interactions as suggested by Kim et al.
soft(x_column) :- channel(_,x), channel(_,column).

% @constraint Positional interactions as suggested by Kim et al.
soft(y_column) :- channel(_,y), channel(_,column).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_high, E) :- channel(E,color), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_low, E) :- channel(E,color), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(size_entropy_high, E) :- channel(E,size), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(size_entropy_low, E) :- channel(E,size), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).

% @constraint Prefer not to use continuous on x, discrete on y, and column.
soft(c_d_column) :- channel_continuous(x), channel_discrete(y), channel(_,column).

% @constraint Prefer time on x.
soft(temporal_y) :- type(E,temporal), not channel(E,x).

% @constraint Prefer not to overlap with DxD.
soft(d_d_overlap) :- is_d_d, overlap.

% ====== Rankings ======
% === Data Types ===

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_q,E) :- type(E,quantitative).

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_o,E) :- type(E,ordinal).

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_n,E) :- type(E,nominal).

% === Mark types ===

% @constraint Continuous by continuous for point mark.
soft(c_c_point) :- is_c_c, mark(point).

% @constraint Continuous by continuous for line mark.
soft(c_c_line) :- is_c_c, mark(line).

% @constraint Continuous by continuous for area mark.
soft(c_c_area) :- is_c_c, mark(area).

% @constraint Continuous by continuous for text mark.
soft(c_c_text) :- is_c_c, mark(text).

% @constraint Continuous by continuous for tick mark.
soft(c_c_tick) :- is_c_c, mark(tick).

% @constraint Continuous by discrete for point mark.
soft(c_d_point) :- is_c_d, not no_overlap, mark(point).

% @constraint Continuous by discrete for bar mark.
soft(c_d_bar) :- is_c_d, not no_overlap, mark(bar).

% @constraint Continuous by discrete for line mark.
soft(c_d_line) :- is_c_d, not no_overlap, mark(line).

% @constraint Continuous by discrete for area mark.
soft(c_d_area) :- is_c_d, not no_overlap, mark(area).

% @constraint Continuous by discrete for text mark.
soft(c_d_text) :- is_c_d, not no_overlap, mark(text).

% @constraint Continuous by discrete for tick mark.
soft(c_d_tick) :- is_c_d, not no_overlap, mark(tick).

% @constraint Continuous by discrete for point mark with no overlap.
soft(c_d_no_overlap_point) :- is_c_d, no_overlap, mark(point).

% @constraint Continuous by discrete for bar mark with no overlap.
soft(c_d_no_overlap_bar) :- is_c_d, no_overlap, mark(bar).

% @constraint Continuous by discrete for line mark with no overlap.
soft(c_d_no_overlap_line) :- is_c_d, no_overlap, mark(line).

% @constraint Continuous by discrete for area mark with no overlap.
soft(c_d_no_overlap_area) :- is_c_d, no_overlap, mark(area).

% @constraint Continuous by discrete for text mark with no overlap.
soft(c_d_no_overlap_text) :- is_c_d, no_overlap, mark(text).

% @constraint Continuous by discrete for tick mark with no overlap.
soft(c_d_no_overlap_tick) :- is_c_d, no_overlap, mark(tick).

% @constraint Discrete by discrete for point mark.
soft(d_d_point) :- is_d_d, mark(point).

% @constraint Discrete by discrete for point mark.
soft(d_d_text) :- is_d_d, mark(text).

% @constraint Discrete by discrete for point mark.
soft(d_d_rect) :- is_d_d, mark(rect).

% === Channel rankings à la APT ===

% @constraint Continuous on x channel.
soft(continuous_x,E) :- channel(E,x), continuous(E).

% @constraint Continuous on y channel.
soft(continuous_y,E) :- channel(E,y), continuous(E).

% @constraint Continuous on color channel.
soft(continuous_color,E) :- channel(E,color), continuous(E).

% @constraint Continuous on size channel.
soft(continuous_size,E) :- channel(E,size), continuous(E).

% @constraint Continuous on text channel.
soft(continuous_text,E) :- channel(E,text), continuous(E).

% @constraint Ordered on x channel.
soft(ordered_x,E) :- channel(E,x), discrete(E), not type(E,nominal).

% @constraint Ordered on y channel.
soft(ordered_y,E) :- channel(E,y), discrete(E), not type(E,nominal).

% @constraint Ordered on color channel.
soft(ordered_color,E) :- channel(E,color), discrete(E), not type(E,nominal).

% @constraint Ordered on size channel.
soft(ordered_size,E) :- channel(E,size), discrete(E), not type(E,nominal).

% @constraint Ordered on text channel.
soft(ordered_text,E) :- channel(E,text), discrete(E), not type(E,nominal).

% @constraint Ordered on row channel.
soft(ordered_row,E) :- channel(E,row), discrete(E), not type(E,nominal).

% @constraint Ordered on column channel.
soft(ordered_column,E) :- channel(E,column), discrete(E), not type(E,nominal).

% @constraint Nominal on x channel.
soft(nominal_x,E) :- channel(E,x), type(E,nominal).

% @constraint Nominal on y channel.
soft(nominal_y,E) :- channel(E,y), type(E,nominal).

% @constraint Nominal on color channel.
soft(nominal_color,E) :- channel(E,color), type(E,nominal).

% @constraint Nominal on shape channel.
soft(nominal_shape,E) :- channel(E,shape), type(E,nominal).

% @constraint Nominal on text channel.
soft(nominal_text,E) :- channel(E,text), type(E,nominal).

% @constraint Nominal on row channel.
soft(nominal_row,E) :- channel(E,row), type(E,nominal).

% @constraint Nominal on column channel.
soft(nominal_column,E) :- channel(E,column), type(E,nominal).

% @constraint Nominal on detail channel.
soft(nominal_detail,E) :- channel(E,detail), type(E,nominal).

% @constraint Interesting on x channel.
soft(interesting_x,E) :- channel(E,x), enc_interesting(E).

% @constraint Interesting on y channel.
soft(interesting_y,E) :- channel(E,y), enc_interesting(E).

% @constraint Interesting on color channel.
soft(interesting_color,E) :- channel(E,color), enc_interesting(E).

% @constraint Interesting on size channel.
soft(interesting_size,E) :- channel(E,size), enc_interesting(E).

% @constraint Interesting on shape channel.
soft(interesting_shape,E) :- channel(E,shape), enc_interesting(E).

% @constraint Interesting on text channel.
soft(interesting_text,E) :- channel(E,text), enc_interesting(E).

% @constraint Interesting on row channel.
soft(interesting_row,E) :- channel(E,row), enc_interesting(E).

% @constraint Interesting on column channel.
soft(interesting_column,E) :- channel(E,column), enc_interesting(E).

% @constraint Interesting on detail channel.
soft(interesting_detail,E) :- channel(E,detail), enc_interesting(E).

% === Aggregations ===

% @constraint Count as aggregate op.
soft(aggregate_count,E) :- aggregate(E,count).

% @constraint Sum as aggregate op.
soft(aggregate_sum,E) :- aggregate(E,sum).

% @constraint Mean as aggregate op.
soft(aggregate_mean,E) :- aggregate(E,mean).

% @constraint Median as aggregate op.
soft(aggregate_median,E) :- aggregate(E,median).

% @constraint Min as aggregate op.
soft(aggregate_min,E) :- aggregate(E,min).

% @constraint Max as aggregate op.
soft(aggregate_max,E) :- aggregate(E,max).

% @constraint Standard Deviation as aggregate op.
soft(aggregate_stdev,E) :- aggregate(E,stdev).

% === Stack ===

% @constraint Zero base for stack op.
soft(stack_zero) :- stack(zero).

% @constraint Normalize between groupbys as stack op.
soft(stack_normalize) :- stack(normalize).

% === Task - marktype correlations ===

% @constraint Point mark for value tasks.
soft(value_point) :- task(value), mark(point).

% @constraint Bar mark for value tasks.
soft(value_bar) :- task(value), mark(bar).

% @constraint Line mark for value tasks.
soft(value_line) :- task(value), mark(line).

% @constraint Area mark for value tasks.
soft(value_area) :- task(value), mark(area).

% @constraint Text mark for value tasks.
soft(value_text) :- task(value), mark(text).

% @constraint Tick mark for value tasks.
soft(value_tick) :- task(value), mark(tick).
% @end

% @constraint Rect mark for value tasks.
soft(value_rect) :- task(value), mark(rect).

% @constraint Point mark for summary tasks.
soft(summary_point) :- task(summary), mark(point).

% @constraint Bar mark for summary tasks.
soft(summary_bar) :- task(summary), mark(bar).

% @constraint Line mark for summary tasks.
soft(summary_line) :- task(summary), mark(line).

% @constraint Area mark for summary tasks.
soft(summary_area) :- task(summary), mark(area).

% @constraint Text mark for summary tasks.
soft(summary_text) :- task(summary), mark(text).

% @constraint Tick mark for summary tasks.
soft(summary_tick) :- task(summary), mark(tick).

% @constraint Rect mark for summary tasks.
soft(summary_rect) :- task(summary), mark(rect).

% === Task - channel correlations ===

% @constraint Continuous x for value tasks.
soft(value_continuous_x,E) :- task(value), channel(E,x), continuous(E), enc_interesting(E).

% @constraint Continuous y for value tasks.
soft(value_continuous_y,E) :- task(value), channel(E,y), continuous(E), enc_interesting(E).

% @constraint Continuous color for value tasks.
soft(value_continuous_color,E) :- task(value), channel(E,color), continuous(E), enc_interesting(E).

% @constraint Continuous size for value tasks.
soft(value_continuous_size,E) :- task(value), channel(E,size), continuous(E), enc_interesting(E).

% @constraint Continuous text for value tasks.
soft(value_continuous_text,E) :- task(value), channel(E,text), continuous(E), enc_interesting(E).

% @constraint Discrete x for value tasks.
soft(value_discrete_x,E) :- task(value), channel(E,x), discrete(E), enc_interesting(E).

% @constraint Discrete y for value tasks.
soft(value_discrete_y,E) :- task(value), channel(E,y), discrete(E), enc_interesting(E).

% @constraint Discrete color for value tasks.
soft(value_discrete_color,E) :- task(value), channel(E,color), discrete(E), enc_interesting(E).

% @constraint Discrete shape for value tasks.
soft(value_discrete_shape,E) :- task(value), channel(E,shape), discrete(E), enc_interesting(E).

% @constraint Discrete size for value tasks.
soft(value_discrete_size,E) :- task(value), channel(E,size), discrete(E), enc_interesting(E).

% @constraint Discrete text for value tasks.
soft(value_discrete_text,E) :- task(value), channel(E,text), discrete(E), enc_interesting(E).

% @constraint Discrete row for value tasks.
soft(value_discrete_row,E) :- task(value), channel(E,row), discrete(E), enc_interesting(E).

% @constraint Discrete column for value tasks.
soft(value_discrete_column,E) :- task(value), channel(E,column), discrete(E), enc_interesting(E).

% @constraint Continuous x for summary tasks.
soft(summary_continuous_x,E) :- task(summary), channel(E,x), continuous(E), enc_interesting(E).

% @constraint Continuous y for summary tasks.
soft(summary_continuous_y,E) :- task(summary), channel(E,y), continuous(E), enc_interesting(E).

% @constraint Continuous color for summary tasks.
soft(summary_continuous_color,E) :- task(summary), channel(E,color), continuous(E), enc_interesting(E).

% @constraint Continuous size for summary tasks.
soft(summary_continuous_size,E) :- task(summary), channel(E,size), continuous(E), enc_interesting(E).

% @constraint Continuous text for summary tasks.
soft(summary_continuous_text,E) :- task(summary), channel(E,text), continuous(E), enc_interesting(E).

% @constraint Discrete x for summary tasks.
soft(summary_discrete_x,E) :- task(summary), channel(E,x), discrete(E), enc_interesting(E).

% @constraint Discrete y for summary tasks.
soft(summary_discrete_y,E) :- task(summary), channel(E,y), discrete(E), enc_interesting(E).

% @constraint Discrete color for summary tasks.
soft(summary_discrete_color,E) :- task(summary), channel(E,color), discrete(E), enc_interesting(E).

% @constraint Discrete shape for summary tasks.
soft(summary_discrete_shape,E) :- task(summary), channel(E,shape), discrete(E), enc_interesting(E).

% @constraint Discrete size for summary tasks.
soft(summary_discrete_size,E) :- task(summary), channel(E,size), discrete(E), enc_interesting(E).

% @constraint Discrete text for summary tasks.
soft(summary_discrete_text,E) :- task(summary), channel(E,text), discrete(E), enc_interesting(E).

% @constraint Discrete row for summary tasks.
soft(summary_discrete_row,E) :- task(summary), channel(E,row), discrete(E), enc_interesting(E).

% @constraint Discrete column for summary tasks.
soft(summary_discrete_column,E) :- task(summary), channel(E,column), discrete(E), enc_interesting(E).

`;

export const WEIGHTS: string = `% Weights as constants

#const type_q_weight = 0.
#const type_o_weight = 1.
#const type_n_weight = 2.
#const aggregate_weight = 1.
#const bin_weight = 2.
#const bin_high_weight = 10.
#const bin_low_weight = 6.
#const encoding_weight = 0.
#const encoding_field_weight = 6.
#const same_field_2_weight = 8.
#const same_field_gte3_weight = 16.
#const count_twice_weight = 50.
#const shape_cardinality_weight = 5.
#const number_nominal_weight = 10.
#const bin_cardinality_weight = 5.
#const quant_bin_weight = 1.
#const agg_dim_weight = 2.
#const only_discrete_weight = 30.
#const multiple_non_pos_weight = 3.
#const non_positional_pref_weight = 10.
#const aggregate_group_by_raw_weight = 3.
#const x_y_raw_weight = 1.
#const log_weight = 1.
#const zero_weight = 1.
#const zero_size_weight = 3.
#const zero_positional_weight = 1.
#const zero_skew_weight = 5.
#const includes_zero_weight = 10.

#const only_x_weight = 1.
#const orientation_binned_weight = 1.
#const high_cardinality_ordinal_weight = 10.
#const high_cardinality_nominal_weight = 10.
#const high_cardinality_nominal_color_weight = 10.
#const horizontal_scrolling_weight = 20.
#const temporal_date_weight = 1.
#const quantitative_numbers_weight = 2.
#const position_entropy_weight = 2.
#const high_cardinality_size_weight = 1.
#const value_agg_weight = 1.
#const facet_summary_weight = 0.
#const x_row_weight = 1.
#const y_row_weight = 1.
#const x_column_weight = 1.
#const y_column_weight = 1.
#const color_entropy_high_weight = 0.
#const color_entropy_low_weight = 0.
#const size_entropy_high_weight = 0.
#const size_entropy_low_weight = 0.

#const c_d_column_weight = 5.
#const temporal_y_weight = 1.
#const d_d_overlap_weight = 20.

#const c_c_point_weight = 0.
#const c_c_line_weight = 20.
#const c_c_area_weight = 20.
#const c_c_text_weight = 2.
#const c_c_tick_weight = 5.

#const c_d_point_weight = 10.
#const c_d_bar_weight = 20.
#const c_d_line_weight = 20.
#const c_d_area_weight = 20.
#const c_d_text_weight = 50.
#const c_d_tick_weight = 0.

#const c_d_no_overlap_point_weight = 20.
#const c_d_no_overlap_bar_weight = 0.
#const c_d_no_overlap_line_weight = 20.
#const c_d_no_overlap_area_weight = 20.
#const c_d_no_overlap_text_weight = 30.
#const c_d_no_overlap_tick_weight = 25.

#const d_d_point_weight = 0.
#const d_d_text_weight = 1.
#const d_d_rect_weight = 0.

#const continuous_x_weight = 0.
#const continuous_y_weight = 0.
#const continuous_color_weight = 10.
#const continuous_size_weight = 1.
#const continuous_text_weight = 20.

#const ordered_x_weight = 1.
#const ordered_y_weight = 0.
#const ordered_color_weight = 8.
#const ordered_size_weight = 10.
#const ordered_text_weight = 32.
#const ordered_row_weight = 10.
#const ordered_column_weight = 10.

#const nominal_x_weight = 3.
#const nominal_y_weight = 0.
#const nominal_color_weight = 10.
#const nominal_shape_weight = 11.
#const nominal_text_weight = 12.
#const nominal_row_weight = 7.
#const nominal_column_weight = 10.
#const nominal_detail_weight = 20.

#const interesting_x_weight = 0.
#const interesting_y_weight = 1.
#const interesting_color_weight = 2.
#const interesting_size_weight = 2.
#const interesting_shape_weight = 3.
#const interesting_text_weight = 6.
#const interesting_row_weight = 6.
#const interesting_column_weight = 7.
#const interesting_detail_weight = 20.

#const aggregate_count_weight = 0.
#const aggregate_sum_weight = 2.
#const aggregate_mean_weight = 1.
#const aggregate_median_weight = 3.
#const aggregate_min_weight = 4.
#const aggregate_max_weight = 4.
#const aggregate_stdev_weight = 5.

#const value_point_weight = 0.
#const value_bar_weight = 0.
#const value_line_weight = 0.
#const value_area_weight = 0.
#const value_text_weight = 0.
#const value_tick_weight = 0.
#const value_rect_weight = 0.
#const summary_point_weight = 0.
#const summary_bar_weight = 0.
#const summary_line_weight = 0.
#const summary_area_weight = 0.
#const summary_text_weight = 0.
#const summary_tick_weight = 0.
#const summary_rect_weight = 0.

#const value_continuous_x_weight = 0.
#const value_continuous_y_weight = 0.
#const value_continuous_color_weight = 0.
#const value_continuous_size_weight = 0.
#const value_continuous_text_weight = 0.
#const value_discrete_x_weight = 0.
#const value_discrete_y_weight = 0.
#const value_discrete_color_weight = 0.
#const value_discrete_shape_weight = 0.
#const value_discrete_size_weight = 0.
#const value_discrete_text_weight = 0.
#const value_discrete_row_weight = 0.
#const value_discrete_column_weight = 0.
#const summary_continuous_x_weight = 0.
#const summary_continuous_y_weight = 0.
#const summary_continuous_color_weight = 0.
#const summary_continuous_size_weight = 0.
#const summary_continuous_text_weight = 0.
#const summary_discrete_x_weight = 0.
#const summary_discrete_y_weight = 0.
#const summary_discrete_color_weight = 0.
#const summary_discrete_shape_weight = 0.
#const summary_discrete_size_weight = 0.
#const summary_discrete_text_weight = 0.
#const summary_discrete_row_weight = 0.
#const summary_discrete_column_weight = 0.

#const stack_zero_weight = 0.
#const stack_normalize_weight = 1.

`;

export const ASSIGN_WEIGHTS: string = `%% GENERATED FILE. DO NOT EDIT.

soft_weight(type_q,type_q_weight).
soft_weight(type_o,type_o_weight).
soft_weight(type_n,type_n_weight).
soft_weight(aggregate,aggregate_weight).
soft_weight(bin,bin_weight).
soft_weight(bin_high,bin_high_weight).
soft_weight(bin_low,bin_low_weight).
soft_weight(encoding,encoding_weight).
soft_weight(encoding_field,encoding_field_weight).
soft_weight(same_field_2,same_field_2_weight).
soft_weight(same_field_gte3,same_field_gte3_weight).
soft_weight(count_twice,count_twice_weight).
soft_weight(shape_cardinality,shape_cardinality_weight).
soft_weight(number_nominal,number_nominal_weight).
soft_weight(bin_cardinality,bin_cardinality_weight).
soft_weight(quant_bin,quant_bin_weight).
soft_weight(agg_dim,agg_dim_weight).
soft_weight(only_discrete,only_discrete_weight).
soft_weight(multiple_non_pos,multiple_non_pos_weight).
soft_weight(non_positional_pref,non_positional_pref_weight).
soft_weight(aggregate_group_by_raw,aggregate_group_by_raw_weight).
soft_weight(x_y_raw,x_y_raw_weight).
soft_weight(log,log_weight).
soft_weight(zero,zero_weight).
soft_weight(zero_size,zero_size_weight).
soft_weight(zero_positional,zero_positional_weight).
soft_weight(zero_skew,zero_skew_weight).
soft_weight(includes_zero,includes_zero_weight).
soft_weight(only_x,only_x_weight).
soft_weight(orientation_binned,orientation_binned_weight).
soft_weight(high_cardinality_ordinal,high_cardinality_ordinal_weight).
soft_weight(high_cardinality_nominal,high_cardinality_nominal_weight).
soft_weight(high_cardinality_nominal_color,high_cardinality_nominal_color_weight).
soft_weight(horizontal_scrolling,horizontal_scrolling_weight).
soft_weight(temporal_date,temporal_date_weight).
soft_weight(quantitative_numbers,quantitative_numbers_weight).
soft_weight(position_entropy,position_entropy_weight).
soft_weight(high_cardinality_size,high_cardinality_size_weight).
soft_weight(value_agg,value_agg_weight).
soft_weight(facet_summary,facet_summary_weight).
soft_weight(x_row,x_row_weight).
soft_weight(y_row,y_row_weight).
soft_weight(x_column,x_column_weight).
soft_weight(y_column,y_column_weight).
soft_weight(color_entropy_high,color_entropy_high_weight).
soft_weight(color_entropy_low,color_entropy_low_weight).
soft_weight(size_entropy_high,size_entropy_high_weight).
soft_weight(size_entropy_low,size_entropy_low_weight).
soft_weight(c_d_column,c_d_column_weight).
soft_weight(temporal_y,temporal_y_weight).
soft_weight(d_d_overlap,d_d_overlap_weight).
soft_weight(c_c_point,c_c_point_weight).
soft_weight(c_c_line,c_c_line_weight).
soft_weight(c_c_area,c_c_area_weight).
soft_weight(c_c_text,c_c_text_weight).
soft_weight(c_c_tick,c_c_tick_weight).
soft_weight(c_d_point,c_d_point_weight).
soft_weight(c_d_bar,c_d_bar_weight).
soft_weight(c_d_line,c_d_line_weight).
soft_weight(c_d_area,c_d_area_weight).
soft_weight(c_d_text,c_d_text_weight).
soft_weight(c_d_tick,c_d_tick_weight).
soft_weight(c_d_no_overlap_point,c_d_no_overlap_point_weight).
soft_weight(c_d_no_overlap_bar,c_d_no_overlap_bar_weight).
soft_weight(c_d_no_overlap_line,c_d_no_overlap_line_weight).
soft_weight(c_d_no_overlap_area,c_d_no_overlap_area_weight).
soft_weight(c_d_no_overlap_text,c_d_no_overlap_text_weight).
soft_weight(c_d_no_overlap_tick,c_d_no_overlap_tick_weight).
soft_weight(d_d_point,d_d_point_weight).
soft_weight(d_d_text,d_d_text_weight).
soft_weight(d_d_rect,d_d_rect_weight).
soft_weight(continuous_x,continuous_x_weight).
soft_weight(continuous_y,continuous_y_weight).
soft_weight(continuous_color,continuous_color_weight).
soft_weight(continuous_size,continuous_size_weight).
soft_weight(continuous_text,continuous_text_weight).
soft_weight(ordered_x,ordered_x_weight).
soft_weight(ordered_y,ordered_y_weight).
soft_weight(ordered_color,ordered_color_weight).
soft_weight(ordered_size,ordered_size_weight).
soft_weight(ordered_text,ordered_text_weight).
soft_weight(ordered_row,ordered_row_weight).
soft_weight(ordered_column,ordered_column_weight).
soft_weight(nominal_x,nominal_x_weight).
soft_weight(nominal_y,nominal_y_weight).
soft_weight(nominal_color,nominal_color_weight).
soft_weight(nominal_shape,nominal_shape_weight).
soft_weight(nominal_text,nominal_text_weight).
soft_weight(nominal_row,nominal_row_weight).
soft_weight(nominal_column,nominal_column_weight).
soft_weight(nominal_detail,nominal_detail_weight).
soft_weight(interesting_x,interesting_x_weight).
soft_weight(interesting_y,interesting_y_weight).
soft_weight(interesting_color,interesting_color_weight).
soft_weight(interesting_size,interesting_size_weight).
soft_weight(interesting_shape,interesting_shape_weight).
soft_weight(interesting_text,interesting_text_weight).
soft_weight(interesting_row,interesting_row_weight).
soft_weight(interesting_column,interesting_column_weight).
soft_weight(interesting_detail,interesting_detail_weight).
soft_weight(aggregate_count,aggregate_count_weight).
soft_weight(aggregate_sum,aggregate_sum_weight).
soft_weight(aggregate_mean,aggregate_mean_weight).
soft_weight(aggregate_median,aggregate_median_weight).
soft_weight(aggregate_min,aggregate_min_weight).
soft_weight(aggregate_max,aggregate_max_weight).
soft_weight(aggregate_stdev,aggregate_stdev_weight).
soft_weight(value_point,value_point_weight).
soft_weight(value_bar,value_bar_weight).
soft_weight(value_line,value_line_weight).
soft_weight(value_area,value_area_weight).
soft_weight(value_text,value_text_weight).
soft_weight(value_tick,value_tick_weight).
soft_weight(value_rect,value_rect_weight).
soft_weight(summary_point,summary_point_weight).
soft_weight(summary_bar,summary_bar_weight).
soft_weight(summary_line,summary_line_weight).
soft_weight(summary_area,summary_area_weight).
soft_weight(summary_text,summary_text_weight).
soft_weight(summary_tick,summary_tick_weight).
soft_weight(summary_rect,summary_rect_weight).
soft_weight(value_continuous_x,value_continuous_x_weight).
soft_weight(value_continuous_y,value_continuous_y_weight).
soft_weight(value_continuous_color,value_continuous_color_weight).
soft_weight(value_continuous_size,value_continuous_size_weight).
soft_weight(value_continuous_text,value_continuous_text_weight).
soft_weight(value_discrete_x,value_discrete_x_weight).
soft_weight(value_discrete_y,value_discrete_y_weight).
soft_weight(value_discrete_color,value_discrete_color_weight).
soft_weight(value_discrete_shape,value_discrete_shape_weight).
soft_weight(value_discrete_size,value_discrete_size_weight).
soft_weight(value_discrete_text,value_discrete_text_weight).
soft_weight(value_discrete_row,value_discrete_row_weight).
soft_weight(value_discrete_column,value_discrete_column_weight).
soft_weight(summary_continuous_x,summary_continuous_x_weight).
soft_weight(summary_continuous_y,summary_continuous_y_weight).
soft_weight(summary_continuous_color,summary_continuous_color_weight).
soft_weight(summary_continuous_size,summary_continuous_size_weight).
soft_weight(summary_continuous_text,summary_continuous_text_weight).
soft_weight(summary_discrete_x,summary_discrete_x_weight).
soft_weight(summary_discrete_y,summary_discrete_y_weight).
soft_weight(summary_discrete_color,summary_discrete_color_weight).
soft_weight(summary_discrete_shape,summary_discrete_shape_weight).
soft_weight(summary_discrete_size,summary_discrete_size_weight).
soft_weight(summary_discrete_text,summary_discrete_text_weight).
soft_weight(summary_discrete_row,summary_discrete_row_weight).
soft_weight(summary_discrete_column,summary_discrete_column_weight).
soft_weight(stack_zero,stack_zero_weight).
soft_weight(stack_normalize,stack_normalize_weight).

`;

export const OPTIMIZE: string = `% Minimize the feature weight

#minimize { W,F,Q: soft_weight(F,W), soft(F,Q); #inf,F,Q: soft(F,Q), not soft_weight(F,_); #inf,F: hard(F); #inf,F,Q: hard(F,Q); #inf,F,Q1,Q2: hard(F,Q1,Q2) }.

`;

export const OUTPUT: string = `% ====== Output ======

#show data/1.

#show mark/1.

#show type/2.
#show channel/2.
#show field/2.
#show aggregate/2.
#show bin/2.
#show stack/2.

#show log/1.
#show zero/1.

#show soft/2.

`;
