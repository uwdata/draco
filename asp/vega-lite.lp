#script (python)

#end.

% ====== Definitions ======

marktype(point;bar;line;area;rule;text;tick;rect).
type(q;o;n;t).
primitive_type(string;number;integer;boolean;date).
aggregate(count;mean;median;min;max).
bin(3;5;10;100;200).
scale(ordinal;linear;log;time).

% channels
single_channel(x;y;color;opacity;size;shape;text).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).

non_positional(color;opacity;size;shape;text;detail).

field(F) :- fieldtype(F,_).

% ====== Generate ======

% pick one marktype
{ mark(M) : marktype(M) } = 1.

% encodings

% maximum number for each multi channel encoding
#const max_extra_encs = 5.

obj_id(0..max_extra_encs).

{ encoding(E): obj_id(E) }.

encoding(Id-1) :- encoding(Id), obj_id(Id), Id > 0.

% properties of encodings

% channel and type have to be present
{ channel(E,C): channel(C) } = 1 :- encoding(E).
{ type(E,T): type(T) } = 1 :- encoding(E).
{ scale(E,S): scale(S) } = 1 :- encoding(E).

% other properties that are not required
0 { field(E,F): field(F) } 1 :- encoding(E).
0 { aggregate(E,A): aggregate(A) } 1 :- encoding(E).
0 { bin(E,B): bin(B) } 1 :- encoding(E).
0 { zero(E) } 1 :- encoding(E).


% ====== Helpers ======

dimension(E) :- type(E,(n;o)), not aggregate(E,_).
dimension(E) :- bin(E,_).

channel_dim(C) :- dimension(E), channel(E,C).
channel_meas(C) :- not dimension(E), channel(E,C).

% orientation for bars and ticks
orientation(horizontal) :- mark(bar;tick), channel_dim(x).
orientation(vertical) :- mark(bar;tick), channel_dim(y).

cardinality(E,C) :- field(E,F), cardinality(F,C).
fieldtype(E,T) :- field(E,F), fieldtype(F,T).


% ====== Constraints ======

% === Within Encodings ===

% primitive type has to support data type
:- type(E,(q;t)), fieldtype(E,(string;boolean)).

% only use temporal type with dates
:- type(E,t), not fieldtype(E,date).

% can only bin quantitative
:- type(E,T), bin(E,_), T != q.

% can only use time scale if type is temporal
:- scale(E,time), not type(E,t).

% can not use linear or log with ordinal or nominal
:- scale(E,(linear;log)), type(E,(o;n)).

% bin requires linear or ordinal scale
:- bin(E,_), not scale(E,linear), not scale(E,ordinal).

% do not use scale zero with dimension (which includes binned)
:- zero(E), dimension(E).

% do not use log scale with dimension
:- scale(E,log), dimension(E).

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
:- mark(bar;area), scale(E,log), channel(E,(x;y)).

% rect mark needs dimension x and y
:- mark(rect), not channel_dim(x).
:- mark(rect), not channel_dim(y).

% === Type checks ===

% fieldtype has to be primitive type
:- fieldtype(_,T), not primitive_type(T).

% check types of encoding properties
:- channel(_,C), not channel(C).
:- field(_,F), not field(F).
:- type(_,T), not type(T).
:- aggregate(_,A), not aggregate(A).
:- bin(_,B), not bin(B).
:- scale(_,S), not scale(S).


% ====== Preferences ======

% prefer quantitative > ordinal > nominal
#const type_weight_q = 0.
#const type_weight_o = 1.
#const type_weight_n = 2.

:~ type(_,q). [type_weight_q@1]
:~ type(_,o). [type_weight_o@1]
:~ type(_,n). [type_weight_n@1]

% prefer to use raw (no aggregate)
#const agg_weight = 1.
:~ aggregate(_,_). [agg_weight@1]

% prefer to use fewer encodings
#const encoding_weight = 6.
#minimize {encoding_weight@1,E: encoding(E)}.

% prefer not to use the same field twice
#const twice_weight = 10.
:~ 2 { field(E,_) }, encoding(E). [twice_weight@1]

% categorical color channel should not have too high cardinality
:~ channel(E,color), type(E,n), cardinality(E,C), C > 20. [5@1]

% shape channel should not have too high cardinality
:~ channel(E,shape), cardinality(E,C), C > 6. [5@1]

% numbers should not be nominal
:~ type(E,n), field(E,F), fieldtype(F,number). [2@1]

% bar and tick should not use size
:~ mark(bar;tick), channel(_,size). [5@1]

% binned quantitative field should not have too low cardinality
:~ type(E,q), bin(E,_), cardinality(E,C), C < 15. [5@1]

% prefer linear scale for bin
:~ bin(E,_), scale(E,ordinal). [1@1]

% aggregate should also have a dimension
:~ aggregate(_,_), not dimension(_). [2@1]

% plots with only ordinal, binned q, or t with time unit should add count
:~ not not dimension(_), not aggregate(_,count). [20@1]

% don't use bar, line, or area for raw data as it leads to occulusion
:~ mark(bar;line;area), not aggregate(_,_). [2@1]

% prefer not to use multiple non-positional encoding channels
#const multiple_non_pos_weight = 3.
:~ {channel(_,C): non_positional(C)} > 1. [multiple_non_pos_weight@1]

% prefer not to use non-positional channels until all positional channels are used
#const non_positional_pref_weight = 10.
:~ channel(_,C), non_positional(C), not channel(_,(x;y)). [non_positional_pref_weight@1]

% aggregate plots should not use raw continuous as group by
:~ aggregate(_,_), type(E,q), not aggregate(E,_). [1@1]

% prefer not to use vertical for dot plot
:~ channel(_,y), not channel(_,C), C != y, channel(C), not mark(bar). [5@1]

% prefer not to use plot with both x and y dimension and no aggregate
:~ channel(EX,x), dimension(EX), channel(EY,y), dimension(EY), not aggregate(_,_). [2@1]

% prefer not to use log scale
:~ scale(E,log), encoding(E). [1@1]


% ====== Rankings ======

% measure by measure
is_m_m :- channel_meas(x), channel_meas(y).

:~ is_m_m, mark(point). [0@1]
:~ is_m_m, mark(bar). [20@1]
:~ is_m_m, mark(line). [20@1]
:~ is_m_m, mark(area). [20@1]
:~ is_m_m, mark(rule). [25@1]
:~ is_m_m, mark(text). [2@1]
:~ is_m_m, mark(tick). [5@1]
:~ is_m_m, mark(rect). [10@1]

% measure by dimension
is_m_d :- channel_meas(x), channel_dim(y).
is_m_d :- channel_meas(y), channel_dim(x).

:~ is_m_d, mark(point). [0@1]
:~ is_m_d, mark(bar). [20@1]
:~ is_m_d, mark(line). [20@1]
:~ is_m_d, mark(area). [20@1]
:~ is_m_d, mark(rule). [25@1]
:~ is_m_d, mark(text). [50@1]
:~ is_m_d, mark(tick). [10@1]
:~ is_m_d, mark(rect). [20@1]

% dimension by dimension
is_d_d :- channel_dim(x), channel_dim(y).

:~ is_m_d, mark(point). [0@1]
:~ is_m_d, mark(bar). [20@1]
:~ is_m_d, mark(line). [20@1]
:~ is_m_d, mark(area). [20@1]
:~ is_m_d, mark(rule). [25@1]
:~ is_m_d, mark(text). [1@1]
:~ is_m_d, mark(tick). [10@1]
:~ is_m_d, mark(rect). [0@1]

% ====== Output ======
#show mark/1.

#show type/2.
#show channel/2.
#show field/2.
#show aggregate/2.
#show bin/2.
#show scale/2.
#show zero/1.
