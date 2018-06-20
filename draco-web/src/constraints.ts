export const TOPK_LUA: string = `#script(lua)

function main(prg)
    local count = tonumber(prg.configuration.solve.models)
    local backend = prg.backend

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
#end.`;

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

% Define a fake violation/2 for all violation/1.
violation(F,_placeholder) :- violation(F).

% Silence warnings about properties never appearing in head.
entropy(0,0) :- #false.
interesting(0) :- #false.
extent(0,0,0) :- #false.
violation(0) :- #false.
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

orientation(horizontal) :- mark(bar;tick;area;line), channel_discrete(y).`;

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

0 { stack(S): stacking(S) } 1.`;

export const HARD: string = `% ====== Expressiveness and Well-Formedness Constraints ======

% === Within Encodings ===

% Primitive type has to support data type.
:- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).
:- type(E,temporal), field(E,F), not fieldtype(F,datetime).

% Can only bin quantitative or ordinal.
:- type(E,T), bin(E,_), T != quantitative, T != ordinal.

% Can only use log with quantitative.
:- log(E), not type(E,quantitative).

% Can only use zero with quantitative.
:- zero(E), not type(E,quantitative).

% Cannot use log scale with discrete (which includes binned).
:- log(E), discrete(E).

% Cannot use log and zero together.
:- log(E), zero(E).

% Cannot use log if the data is negative or zero.
:- log(E), field(E,F), extent(F,MIN,_), MIN <= 0.

% Cannot bin and aggregate.
:- bin(E,_), aggregate(E,_).

% Oridnal only supports min, max, and median.
:- type(E,ordinal), aggregate(E,A), A != min, A != max, A != median.

% Temporal only supports min and max.
:- type(E,temporal), aggregate(E,A), A != min, A != max.

% Cannot aggregate nominal.
:- aggregate(E,_), type(E,nominal).

% Detail cannot be aggregated.
:- channel(E,detail), aggregate(E,_).

% Count has to be quantitative and not use a field.
:- aggregate(E,count), field(E,_).
:- aggregate(E,count), not type(E,quantitative).

% Shape requires discrete and not ordered (nominal).
% Using ordinal would't make a difference in Vega-Lite.
:- channel(E,shape), not type(E,nominal).

% Detail requires nominal.
:- channel(E,detail), not type(E,nominal).

% Size implies order so nominal is misleading.
:- channel(E,size), type(E,nominal).

% Do not use size when data is negative as size implies that data is positive.
:- channel(E,size), enc_extent(E,MIN,MAX), MIN < 0, MAX > 0.

% === Across encodings and between encodings and marks ===

% Cannot use single channels twice.
:- single_channel(C), 2 { channel(_,C) }.

% There has to be at least one encoding. Otherwise, the visualization doesn't show anything.
:- not encoding(_).

% Row and column require discrete.
:- channel_continuous(row;column).

% Don't use row without y. Just using y is simpler.
:- channel(_,row), not channel(_,y).

% Don't use column without x. Just using x is simpler.
:- channel(_,column), not channel(_,x).

% All encodings (if they have a channel) require field except if we have a count aggregate.
:- not field(E,_), not aggregate(E,count), encoding(E).

% Count should not have a field. Having a field doesn't make a difference.
:- aggregate(E,count), field(E,_).

% Text mark requires text channel.
:- mark(text), not channel(_,text).

% Text channel requires text mark.
:- channel(_,text), not mark(text).

% Point, tick, and bar require x or y channel.
:- mark(point;tick;bar), not channel(_,x), not channel(_,y).

% Line and area require x and y channel.
:- mark(line;area), not channel(_,(x;y)).

% Line and area cannot have two discrete.
:- mark(line;area), channel_discrete(x), channel_discrete(y).

% Bar and tick cannot have both x and y continuous.
:- mark(bar;tick), channel_continuous(x), channel_continuous(y).

% Bar, tick, line, area require some continuous variable on x or y.
:- mark(bar;tick;area;line), not channel_continuous(x), not channel_continuous(y).

% Bar and area mark requires scale of continuous to start at zero.
:- mark(bar;area), channel(E,x), orientation(horizontal), not zero(E).
:- mark(bar;area), channel(E,y), orientation(vertical), not zero(E).

% Shape channel requires point mark.
:- channel(_,shape), not mark(point).

% Size only works with some marks. Vega-Lite can also size lines, and ticks but that would violate best practices.
:- channel(_,size), not mark(point), not mark(text).

% Detail requires aggregation. Detail adds a field to the group by. Detail could also be used to add information to tooltips. We may remove this later.
:- channel(_,detail), not aggregate(_,_).

% Do not use log for bar or area mark as they are often misleading. We may remove this rule in the future.
:- mark(bar;area), log(E), channel(E,(x;y)).

% Rect mark needs discrete x and y.
:- mark(rect), not is_d_d.

% Don't use the same field on x and y.
:- { field(E,F) : channel(E,x); field(E,F) : channel(E,y) } >= 2, field(F).
% Don't use count on x and y.
:- channel(EX,x), channel(EY,y), aggregate(EX,count), aggregate(EY,count).

% If we use aggregation, then all continuous fields need to be aggeragted.
:- aggregate(_,_), continuous(E), not aggregate(E,_).

% Don't use count twice.
:- { aggregate(_,count) } = 2.

% === Global properties ===

% Bars and area cannot overlap.
:- mark(bar;area), overlap.

% Rects shouldn't overlap. They are used for dioscrete heatmaps.
:- mark(rect), overlap.

% == Stacking ==

% Only use stacking for bar and area.
:- stack(_), not mark(bar), not mark(area).

% Don't stack if aggregation is not summative (summative are count, sum, distinct, valid, missing).
:- stack(E,_), aggregate(E,A), not summative_aggregate_op(A).

% Need to stack if we use bar, area with discrete color.
:- mark(bar;area), channel(E,color), discrete(E), not stack(_).

% Can only use stack if we also use discrete color, or detail.
:- stack(_), not channel_discrete(color), not channel(_,detail).

% If we use stack and detail, we also have to use quantitative color.
:- stack(_), channel(_,detail), not channel(_,color).
:- stack(_), channel(_,detail), channel(E,color), not aggregate(E,_).

% Stack can only be on continuous.
:- stack(E,_), discrete(E).

% Stack can only be on x or y.
:- stack(E,_), not channel(E,x), not channel(E,y).

% Cannot use non positional continuous with stack unless it's aggregated.
:- stack(_), non_positional(C), channel(E,C), not aggregate(E,_), continuous(E).

% Vega-Lite currently supports 8 shapes.
:- channel(E,shape), enc_cardinality(E,C), C > 8.

% At most 20 categorical colors.
:- channel(E,color), discrete(E), enc_cardinality(E,C), C > 20.

% === Type checks ===

% Check mark.
:- mark(M), not marktype(M).

% Check types of encoding properties.
:- channel(_,C), not channel(C).
:- field(_,F), not field(F).
:- type(_,T), not type(T).
:- aggregate(_,A), not aggregate_op(A).
:- bin(_,B), not B >= 0.  % Bin has to be a natural number.

% Fieldtype has to be primitive type.
:- fieldtype(_,T), not primitive_type(T).

% Task has to be one of the tasks.
:- task(T), not tasks(T).

% Num_rows has to be larger than 0.
:- num_rows(S), S < 0.

% Cardinality has to be larger than 0.
:- cardinality(_,C), C < 0.

% Entropy has to be positive.
:- entropy(_,E), E < 0.

% Extent only allowed for numbers (for now).
:- extent(F,_,_), not fieldtype(F,number).

% Order has to be correct.
:- extent(_,MIN,MAX), MIN > MAX.

% The name of a field cannot be the name of an encoding.
% This is to prevent errors coming from the shortcuts in define.lp.
:- encoding(N), field(N).`;

export const SOFT: string = `% After adding a soft constraint to this file, make sure to update 'weights.lp' and run 'process_violations.py'..

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
violation(summary_discrete_column,E) :- task(summary), channel(E,column), discrete(E), enc_interesting(E).`;

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
#const stack_normalize_weight = 1.`;

export const ASSIGN_WEIGHTS: string = `%% GENERATED FILE. DO NOT EDIT.

violation_weight(type_q,type_q_weight).
violation_weight(type_o,type_o_weight).
violation_weight(type_n,type_n_weight).
violation_weight(aggregate,aggregate_weight).
violation_weight(bin,bin_weight).
violation_weight(bin_high,bin_high_weight).
violation_weight(bin_low,bin_low_weight).
violation_weight(encoding,encoding_weight).
violation_weight(encoding_field,encoding_field_weight).
violation_weight(same_field_2,same_field_2_weight).
violation_weight(same_field_gte3,same_field_gte3_weight).
violation_weight(count_twice,count_twice_weight).
violation_weight(shape_cardinality,shape_cardinality_weight).
violation_weight(number_nominal,number_nominal_weight).
violation_weight(bin_cardinality,bin_cardinality_weight).
violation_weight(quant_bin,quant_bin_weight).
violation_weight(agg_dim,agg_dim_weight).
violation_weight(only_discrete,only_discrete_weight).
violation_weight(multiple_non_pos,multiple_non_pos_weight).
violation_weight(non_positional_pref,non_positional_pref_weight).
violation_weight(aggregate_group_by_raw,aggregate_group_by_raw_weight).
violation_weight(x_y_raw,x_y_raw_weight).
violation_weight(log,log_weight).
violation_weight(zero,zero_weight).
violation_weight(zero_size,zero_size_weight).
violation_weight(zero_positional,zero_positional_weight).
violation_weight(zero_skew,zero_skew_weight).
violation_weight(includes_zero,includes_zero_weight).
violation_weight(only_x,only_x_weight).
violation_weight(orientation_binned,orientation_binned_weight).
violation_weight(high_cardinality_ordinal,high_cardinality_ordinal_weight).
violation_weight(high_cardinality_nominal,high_cardinality_nominal_weight).
violation_weight(high_cardinality_nominal_color,high_cardinality_nominal_color_weight).
violation_weight(horizontal_scrolling,horizontal_scrolling_weight).
violation_weight(temporal_date,temporal_date_weight).
violation_weight(quantitative_numbers,quantitative_numbers_weight).
violation_weight(position_entropy,position_entropy_weight).
violation_weight(high_cardinality_size,high_cardinality_size_weight).
violation_weight(value_agg,value_agg_weight).
violation_weight(facet_summary,facet_summary_weight).
violation_weight(x_row,x_row_weight).
violation_weight(y_row,y_row_weight).
violation_weight(x_column,x_column_weight).
violation_weight(y_column,y_column_weight).
violation_weight(color_entropy_high,color_entropy_high_weight).
violation_weight(color_entropy_low,color_entropy_low_weight).
violation_weight(size_entropy_high,size_entropy_high_weight).
violation_weight(size_entropy_low,size_entropy_low_weight).
violation_weight(c_d_column,c_d_column_weight).
violation_weight(temporal_y,temporal_y_weight).
violation_weight(d_d_overlap,d_d_overlap_weight).
violation_weight(c_c_point,c_c_point_weight).
violation_weight(c_c_line,c_c_line_weight).
violation_weight(c_c_area,c_c_area_weight).
violation_weight(c_c_text,c_c_text_weight).
violation_weight(c_c_tick,c_c_tick_weight).
violation_weight(c_d_point,c_d_point_weight).
violation_weight(c_d_bar,c_d_bar_weight).
violation_weight(c_d_line,c_d_line_weight).
violation_weight(c_d_area,c_d_area_weight).
violation_weight(c_d_text,c_d_text_weight).
violation_weight(c_d_tick,c_d_tick_weight).
violation_weight(c_d_no_overlap_point,c_d_no_overlap_point_weight).
violation_weight(c_d_no_overlap_bar,c_d_no_overlap_bar_weight).
violation_weight(c_d_no_overlap_line,c_d_no_overlap_line_weight).
violation_weight(c_d_no_overlap_area,c_d_no_overlap_area_weight).
violation_weight(c_d_no_overlap_text,c_d_no_overlap_text_weight).
violation_weight(c_d_no_overlap_tick,c_d_no_overlap_tick_weight).
violation_weight(d_d_point,d_d_point_weight).
violation_weight(d_d_text,d_d_text_weight).
violation_weight(d_d_rect,d_d_rect_weight).
violation_weight(continuous_x,continuous_x_weight).
violation_weight(continuous_y,continuous_y_weight).
violation_weight(continuous_color,continuous_color_weight).
violation_weight(continuous_size,continuous_size_weight).
violation_weight(continuous_text,continuous_text_weight).
violation_weight(ordered_x,ordered_x_weight).
violation_weight(ordered_y,ordered_y_weight).
violation_weight(ordered_color,ordered_color_weight).
violation_weight(ordered_size,ordered_size_weight).
violation_weight(ordered_text,ordered_text_weight).
violation_weight(ordered_row,ordered_row_weight).
violation_weight(ordered_column,ordered_column_weight).
violation_weight(nominal_x,nominal_x_weight).
violation_weight(nominal_y,nominal_y_weight).
violation_weight(nominal_color,nominal_color_weight).
violation_weight(nominal_shape,nominal_shape_weight).
violation_weight(nominal_text,nominal_text_weight).
violation_weight(nominal_row,nominal_row_weight).
violation_weight(nominal_column,nominal_column_weight).
violation_weight(nominal_detail,nominal_detail_weight).
violation_weight(interesting_x,interesting_x_weight).
violation_weight(interesting_y,interesting_y_weight).
violation_weight(interesting_color,interesting_color_weight).
violation_weight(interesting_size,interesting_size_weight).
violation_weight(interesting_shape,interesting_shape_weight).
violation_weight(interesting_text,interesting_text_weight).
violation_weight(interesting_row,interesting_row_weight).
violation_weight(interesting_column,interesting_column_weight).
violation_weight(interesting_detail,interesting_detail_weight).
violation_weight(aggregate_count,aggregate_count_weight).
violation_weight(aggregate_sum,aggregate_sum_weight).
violation_weight(aggregate_mean,aggregate_mean_weight).
violation_weight(aggregate_median,aggregate_median_weight).
violation_weight(aggregate_min,aggregate_min_weight).
violation_weight(aggregate_max,aggregate_max_weight).
violation_weight(aggregate_stdev,aggregate_stdev_weight).
violation_weight(value_point,value_point_weight).
violation_weight(value_bar,value_bar_weight).
violation_weight(value_line,value_line_weight).
violation_weight(value_area,value_area_weight).
violation_weight(value_text,value_text_weight).
violation_weight(value_tick,value_tick_weight).
violation_weight(value_rect,value_rect_weight).
violation_weight(summary_point,summary_point_weight).
violation_weight(summary_bar,summary_bar_weight).
violation_weight(summary_line,summary_line_weight).
violation_weight(summary_area,summary_area_weight).
violation_weight(summary_text,summary_text_weight).
violation_weight(summary_tick,summary_tick_weight).
violation_weight(summary_rect,summary_rect_weight).
violation_weight(value_continuous_x,value_continuous_x_weight).
violation_weight(value_continuous_y,value_continuous_y_weight).
violation_weight(value_continuous_color,value_continuous_color_weight).
violation_weight(value_continuous_size,value_continuous_size_weight).
violation_weight(value_continuous_text,value_continuous_text_weight).
violation_weight(value_discrete_x,value_discrete_x_weight).
violation_weight(value_discrete_y,value_discrete_y_weight).
violation_weight(value_discrete_color,value_discrete_color_weight).
violation_weight(value_discrete_shape,value_discrete_shape_weight).
violation_weight(value_discrete_size,value_discrete_size_weight).
violation_weight(value_discrete_text,value_discrete_text_weight).
violation_weight(value_discrete_row,value_discrete_row_weight).
violation_weight(value_discrete_column,value_discrete_column_weight).
violation_weight(summary_continuous_x,summary_continuous_x_weight).
violation_weight(summary_continuous_y,summary_continuous_y_weight).
violation_weight(summary_continuous_color,summary_continuous_color_weight).
violation_weight(summary_continuous_size,summary_continuous_size_weight).
violation_weight(summary_continuous_text,summary_continuous_text_weight).
violation_weight(summary_discrete_x,summary_discrete_x_weight).
violation_weight(summary_discrete_y,summary_discrete_y_weight).
violation_weight(summary_discrete_color,summary_discrete_color_weight).
violation_weight(summary_discrete_shape,summary_discrete_shape_weight).
violation_weight(summary_discrete_size,summary_discrete_size_weight).
violation_weight(summary_discrete_text,summary_discrete_text_weight).
violation_weight(summary_discrete_row,summary_discrete_row_weight).
violation_weight(summary_discrete_column,summary_discrete_column_weight).
violation_weight(stack_zero,stack_zero_weight).
violation_weight(stack_normalize,stack_normalize_weight).`;

export const OPTIMIZE: string = `% Minimize the feature weight

#minimize { W,F,Q: violation_weight(F,W), violation(F,Q) }.`;

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

#show violation/2.`;
