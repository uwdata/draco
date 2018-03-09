% ====== Constraints ======


% === Within Encodings ===

% primitive type has to support data type
:- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).
:- type(E,temporal), field(E,F), not fieldtype(F,datetime).

% can only bin quantitative or ordinal
:- type(E,T), bin(E,_), T != quantitative, T != ordinal.

% can only use log with quantitative
:- log(E), not type(E,quantitative).

% can only use zero with quantitative
:- zero(E), not type(E,quantitative).

% cannot use log scale with discrete (which includes binned)
:- log(E), discrete(E).

% cannot use log and zero together
:- log(E), zero(E).

% cannot bin and aggregate
:- bin(E,_), aggregate(E,_).

% mean and sum only works for quantitative
:- aggregate(E,(sum;mean)), type(E,T), T != quantitative.

% min, max, and median only work for ordinal and quantitative
:- aggregate(E,(min;max;median)), type(E,T), T != quantitative, T != ordinal.

% count has to be quantitative and not use a field
:- aggregate(E,count), field(E,_).
:- aggregate(E,count), not type(E,quantitative).

% shape requires discrete and not ordered (nominal)
:- channel(E,shape), not type(E,nominal).

% detail requires nominal
:- channel(E,detail), not type(E,nominal).

% size, and opacity impy order so nominal is misleading
:- channel(E,(size;opacity)), type(E,nominal).

% cannot aggregate nominal
:- aggregate(E,_), type(E,nominal).

% can only aggregate ordinal with min and max
:- aggregate(E,A), type(E,ordinal), A != min, A != max.

% detail cannot be aggregated
:- channel(E,detail), aggregate(E,_).

% nominal cannot be aggregated
:- type(E,nominal), aggregate(E,_).

% do not use log or zero when data is negative


% do not use size when data is negative


% === Across encodings and between encodings and marks ===

% cannot use single channels twice
:- single_channel(C), 2 {channel(_,C)}.

% there has to be at least one encoding
:- not encoding(_).

% row and column require discrete
:- channel_continuous(row;column).

% don't use row without y
:- channel(_,row), not channel(_,y).

% don't use column without x
:- channel(_,column), not channel(_,x).

% all encodings (if they have a channel) require field except if we have a count aggregate
:- not field(E,_), not aggregate(E,count), encoding(E).
% count should not have a field
:- aggregate(E,count), field(E,_).

% text mark requires text channel
:- mark(text), not channel(_,text).

% text channel requires text mark
:- channel(_,text), not mark(text).

% point, tick, and bar require x or y channel
:- mark(point;tick;bar), not channel(_,x), not channel(_,y).

% line and area require x and y channel
:- mark(line;area), not channel(_,(x;y)).

% line and area cannot have two discrete
:- mark(line;area), channel_discrete(x), channel_discrete(y).

% bar and tick cannot have both x and y continuous
:- mark(bar;tick), channel_continuous(x), channel_continuous(y).

% bar, tick, line, area require some continuous variable on x or y
:- mark(bar;tick;area;line), not channel_continuous(x), not channel_continuous(y).

% bar and area mark requires scale of continuous to start at zero
:- mark(bar;area), channel(E,(x;y)), continuous(E), not zero(E).

% shape channel requires point mark
:- channel(_,shape), not mark(point).

% size only works with some marks
:- channel(_,size), not mark(point), not mark(text), not mark(line).

% detail requires aggregation
:- channel(_,detail), not aggregate(_,_).

% do not use log for bar or area mark
:- mark(bar;area), log(E), channel(E,(x;y)).

% rect mark needs discrete x and y
:- mark(rect), not is_d_d.

% don't use size with line
:- mark(line), channel(E,size).

% don't use the same field on x and y
:- channel(EX,x), channel(EY,y), field(EX,F), field(EY,F).
% don't use count on x and y
:- channel(EX,x), channel(EY,y), aggregate(EX,count), aggregate(EY,count).

% === Global properties ===

% bars and area cannot overlap
:- mark(bar;area), overlap.

% unless we use size, we should not overlap rect
:- mark(rect), overlap, not channel(_,size).

% == Stacking ==

% only use stacking for bar and area
:- stack(_), not mark(bar), not mark(area).

% don't stack if aggregation is not summative (summative are count, sum, distinct, valid, missing)
:- stack(E,_), aggregate(E,A), not summative_aggregate_op(A).

% need to stack if we use bar, area with discrete color or opacity
:- mark(bar;area), channel(E,(color;opacity)), discrete(E), not stack(_).

% can only use stack if we also use discrete color, opacity, or detail
:- stack(_), not channel_discrete(opacity), not channel_discrete(color), not channel(_,detail).

% stack can only be on continuous
:- stack(E,_), discrete(E).

% stack can only be on x or y
:- stack(E,_), not channel(E,x), not channel(E,y).

% cannot use non positional continuous with stack unless it's aggregated
:- stack(_), non_positional(C), channel(E,C), not aggregate(E,_), continuous(E).

% stack only works with c_d
:- stack(_), not is_c_d.

% === Type checks ===

% check mark

:- mark(M), not marktype(M).

% check types of encoding properties
:- channel(_,C), not channel(C).
:- field(_,F), not field(F).
:- type(_,T), not type(T).
:- aggregate(_,A), not aggregate_op(A).
:- bin(_,B), not B >= 0.  % bin has to be a natural number

% fieldtype has to be primitive type
:- fieldtype(_,T), not primitive_type(T).

% task has to be one of the tasks
:- task(T), not tasks(T).

% data_size has to be larger than 0
:- data_size(S), S <= 0.

% cardinality has to be larger than 0
:- cardinality(_,C), C <= 0.

% entropy has to be positive
:- entropy(_,E), E < 0.

% extent only allowed for numbers (for now)
:- extent(F,_,_), not fieldtype(F,number).

% order has to be correct
:- extent(_,MIN,MAX), MIN > MAX.

% the name of a field cannot be the name of an encoding
% this is to prevent errors coming from the shortcuts in define.lp
:- encoding(N), field(N).
