#script (python)

#end.

% ====== Definitions ======

marktype(point;bar;line;area;rule;symbol;text;tick).
type(q;o;n).
primitive_type(string;number;boolean;date).
aggregate(count;mean;median;min;max).
bin(3;5;10;100;200).
scale(zero;log).

% channels
single_channel(x;y;color;size;shape;text).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).

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

% other properties that are not required
0 { field(E,F): field(F) } 1 :- encoding(E).
0 { aggregate(E,A): aggregate(A) } 1 :- encoding(E).
0 { bin(E,B): bin(B) } 1 :- encoding(E).
0 { scale(E,S): scale(S) } 1 :- encoding(E).


% ====== Helpers ======

dimension(E) :- type(E,(n;o)), not aggregate(E,_).
dimension(E) :- bin(E,_).

channel_dim(C) :- dimension(E), channel(E,C).
channel_meas(C) :- not dimension(E), channel(E,C).

% orientation for bars and ticks
orientation(horizontal) :- mark(bar;tick), channel_dim(x).
orientation(vertical) :- mark(bar;tick), channel_dim(y).

cardinality(E,C) :- field(E,F), cardinality(F,C).


% ====== Constraints ======

% === Within Encodings ===

% primitive type has to support data type
:- type(E,q), field(E,F), fieldtype(F,(string;boolean)).

% can only bin quantitative
:- type(E,T), bin(E,_), T != q.

% do not use scale zero with dimension
:- scale(E,zero), dimension(E).

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

% categorical color channel should not have too high cardinality
:- channel(E,color), cardinality(E,C), C > 20.

% shape channel should not have too high cardinality
:- channel(E,shape), cardinality(E,C), C > 6.

% aggregate implies quantitative
:- aggregate(E,_), not type(E,q).

% numbers should not be nominal
:~ type(E,n), field(E,F), fieldtype(F,number). [2@1]


% === Across encodings and between encodings and marks ===

% cannot use single channels twice
:- single_channel(C), 2 {channel(_,C)}.

% there has to be at least one encoding
:- not encoding(_).

% all encodings (if they have a channel) require field except if we have a count aggregate
:- not field(E,_), not aggregate(E,count), encoding(E).
% count should not have a field
:- aggregate(E,count), field(E,_).

% text mark requires text channel
:- mark(text), not channel(_,text).
% and row or column
:- mark(text), not channel(_,row), not channel(_,column).

% text channel requires text mark
:- channel(_,text), not mark(text).

% point, tick, and bar require x or y channel
:- mark(point;tick;bar), not channel(_,x), not channel(_,y).

% line and area require x and y channel
:- mark(line;area), not channel(_,x).
:- mark(line;area), not channel(_,y).

% bar and tick requires exactly one measure (x or y)
:- mark(bar;tick), not 1 = {channel_meas(x); channel_meas(y)}.

% bar mark requires scale of measure to start at zero
:- mark(bar), type(E,(x;y)), not dimension(E), not scale(E,zero).

% shape channel requires point mark
:- channel(_,shape), not mark(point).

% size only works with some marks
:- channel(_,size), not mark(point), not mark(rule), not mark(text), not mark(line).

% bar and tick should not use size
:~ mark(bar;tick), channel(_,size). [10@1]

% area and line require x and y
:- mark(area;line), not channel(_,x).
:- mark(area;line), not channel(_,y).

% aggregate should also have a dimension
:~ aggregate(_,_), not dimension(_). [2@1]

% detail requires aggregation
:- channel(_,detail), not aggregate(_,_).

% do not use log for bar chart's measure
:- mark(bar), not dimension(E), scale(E,log), channel(E,(x;y)).


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

% type weight
#const tw = 1.

:~ type(_,o). [1*tw@1]
:~ type(_,n). [2*tw@1]

% prefer to use raw (no aggregate)

% aggregate weight
#const aw = 1.

:~ aggregate(_,A), A != null. [aw@1]

% prefer to use fewer encodings

% encoding weight
#const ew = 6.

:~ encoding(_).  [ew@1]

% ====== Output ======
#show mark/1.

#show type/2.
#show channel/2.
#show field/2.
#show aggregate/2.
#show bin/2.
#show scale/2.
