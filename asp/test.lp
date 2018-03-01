% ====== Constraints ======


% === Within Encodings ===

% primitive type has to support data type
:- type(E,quantitative), field(E,F), fieldtype(F,(string;boolean)).
:- type(E,temporal), field(E,F), fieldtype(F,boolean).

% can only bin quantitative or ordinal
:- type(E,T), bin(E,_), T != quantitative, T != ordinal.

% can only use log with quantitative
:- log(E), not type(E,quantitative).

% can only use zero with quantitative
:- zero(E), not type(E,quantitative).

% do not use scale zero with discrete (which includes binned)
:- zero(E), discrete(E).

% cannot use log scale with discrete (which includes binned)
:- log(E), discrete(E).

% cannot bin and aggregate
:- bin(E,_), aggregate(E,_).

% mean and sum only works for quantitative
:- aggregate(E,(sum;mean)), type(E,T), T != quantitative.

% min, max, and median only work for ordinal and quantitative
:- aggregate(E,(min;max;median)), type(E,T), T != quantitative, T != ordinal.

% count has to be quantitative and not use a field
:- aggregate(E,count), field(E,_).
:- aggregate(E,count), not type(E,quantitative).

% shape requires discrete
:- channel_continuous(shape).

% row and column require discrete
:- channel_continuous(row;column).

% aggregate implies quantitative
:- aggregate(E,_), not type(E,quantitative).

% cannot aggregate nominal
:- aggregate(E,_), type(E,nominal).

% can only aggregate ordinal with min and max
:- aggregate(E,A), type(E,ordinal), A != min, A != max.


% === Across encodings and between encodings and marks ===

% cannot use single channels twice
:- single_channel(C), 2 {channel(_,C)}.

% there has to be at least one encoding
:- not encoding(_).

% all encodings (if they have a channel) require field except if we have a count aggregate
:- not field(E,_), not aggregate(E,count), encoding(E).
% count should not have a field
:- aggregate(E,count), field(E,_).

% TODO: check channelPermittedByMarkType

% text mark requires text channel
:- mark(text), not channel(_,text).
% and row or column
:- mark(text), not channel(_,row), not channel(_,column).

% text channel requires text mark
:- channel(_,text), not mark(text).

% point, tick, and bar require x or y channel
:- mark(point;tick;bar;rule), not channel(_,x), not channel(_,y).

% do not use rule if we have x and y
:- mark(rule), channel(_,x), channel(_,y).

% line and area require x and y channel
:- mark(line;area), not channel(_,x).
:- mark(line;area), not channel(_,y).

% bar and tick cannot have both x and y continuous
:- mark(bar;tick), channel_continuous(x), channel_continuous(y).

% bar mark requires scale of continuous to start at zero
:- mark(bar), channel(E,(x;y)), continuous(E), not zero(E).

% shape channel requires point mark
:- channel(_,shape), not mark(point).

% size only works with some marks
:- channel(_,size), not mark(point), not mark(rule), not mark(text), not mark(line).

% area and line require x and y
:- mark(area;line), not channel(_,(x;y)).

% detail requires aggregation
:- channel(_,detail), not aggregate(_,_).

% detail cannot be aggregated
:- channel(E,detail), aggregate(E,_).

% do not use log for bar or area mark
:- mark(bar;area), log(E), channel(E,(x;y)).

% rect mark needs discrete x and y
:- mark(rect), not channel_discrete(x).
:- mark(rect), not channel_discrete(y).

% nominal cannot be aggregated
:- type(E,nominal), aggregate(E,_).

% don't use size with line
:- mark(line), channel(E,size).


% === Global properties ===

% only use stacking for bar, area, line
:- stack(_), not mark(bar), not mark(area), not mark(line).

% don't stack if aggregation is not summative (summative are count, sum, distinct, valid, missing)
:- stack(E,_), aggregate(E,A), not summative_aggregate_op(A).

% stack if no opacity is used for bar and area
:- not channel(_,opacity), mark(bar;area), channel(_,(detail;color;opacity)), not stack(_).

% === Type checks ===

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
