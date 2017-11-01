% ====== Constraints ======


% === Within Encodings ===

% primitive type has to support data type
:- type(E,(q;t)), fieldtype(E,(string;boolean)).

% only use temporal type with dates
:- type(E,t), not fieldtype(E,date).

% can only bin quantitative or ordinal
:- type(E,T), bin(E,_), T != q, T != o.

% cannot use log with ordinal or nominal
:- log(E), type(E,(o;n)).

% do not use scale zero with dimension (which includes binned)
:- zero(E), dimension(E).

% cannot use log scale with dimension (which includes binned)
:- log(E), dimension(E).

% cannot bin and aggregate
:- bin(E,_), aggregate(E,_).

% mean and sum only works for quantitative
:- aggregate(E,(sum;mean)), type(E,T), T != q.

% min, max, and median only work for ordinal and quantitative
:- aggregate(E,(min;max;median)), type(E,T), T != q, T != o.

% count has to be quantitative and not use a field
:- aggregate(E,count), field(E,_).
:- aggregate(E,count), not type(E,q).

% shape requires dimension
:- channel_meas(shape).

% size or text require measure
:- channel_meas(size;text).

% aggregate implies quantitative
:- aggregate(E,_), not type(E,q).

% can only aggregate measures
:- aggergate(E,_), dimension(E).


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

% do not use ruleif we have x and y
:- mark(rule), channel(_,x), channel(_,y).

% line and area require x and y channel
:- mark(line;area), not channel(_,x).
:- mark(line;area), not channel(_,y).

% bar and tick requires exactly one measure (x or y)
:- mark(bar;tick), not 1 = {channel_meas(x); channel_meas(y)}.

% bar mark requires scale of measure to start at zero
:- mark(bar), type(E,(x;y)), not dimension(E), not zero(E).

% shape channel requires point mark
:- channel(_,shape), not mark(point).

% size only works with some marks
:- channel(_,size), not mark(point), not mark(rule), not mark(text), not mark(line).

% area and line require x and y
:- mark(area;line), not channel(_,(x;y)).

% detail requires aggregation
:- channel(_,detail), not aggregate(_,_).

% do not use log for bar or area mark
:- mark(bar;area), log(E), channel(E,(x;y)).

% rect mark needs dimension x and y
:- mark(rect), not channel_dim(x).
:- mark(rect), not channel_dim(y).


% === Type checks ===

% check types of encoding properties
:- channel(_,C), not channel(C).
:- field(_,F), not field(F).
:- type(_,T), not type(T).
:- aggregate(_,A), not aggregate(A).
:- bin(_,B), not bin(B).

% fieldtype has to be primitive type
:- fieldtype(_,T), not primitive_type(T).
