% ====== Expressiveness and Well-Formedness Constraints ======

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
:- encoding(N), field(N).
