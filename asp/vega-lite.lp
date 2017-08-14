% ====== Definitions ======

marktype(point;bar;line;area;rule;symbol;text;tick).
types(q;o;n).
primitive_type(string;number;boolean).
aggregates(null;count;mean;median;min;max).
binning(null;3;5;10;100;200).
scales(null;zero;log).

% channels
single_channels(x;y;color;size;shape;text).
multi_channels(detail).
channels(C) :- single_channels(C).
channels(C) :- multi_channels(C).

% ====== Data definitions ======

% special field for count
fieldtype(one,row).

% ====== Generate ======

% pick one marktype
{ mark(M) : marktype(M) } = 1.

% we can encode fields with channels
0 { encode(C,F,T,A,B,S) : fields(F), types(T), aggregates(A), binning(B), scales(S) } 1 :- single_channels(C).
{ encode(C,F,T,A,B,S) : fields(F), types(T), aggregates(A), binning(B), scales(S) } :- multi_channels(C).

% ====== Helpers ======

% projections of encoding
encode(C,F,T,A,B) :- encode(C,F,T,A,B,_).
encode(C,F,T) :- encode(C,F,T,_,_,_).
encode(C) :- encode(C,_,_,_,_,_).

% extractors
channel(encode(C,F,T,A,B,S), C) :- encode(C,F,T,A,B,S).
field(encode(C,F,T,A,B,S), F) :- encode(C,F,T,A,B,S).
type(encode(C,F,T,A,B,S), T) :- encode(C,F,T,A,B,S).
aggregate(encode(C,F,T,A,B,S), A) :- encode(C,F,T,A,B,S).
bin(encode(C,F,T,A,B,S), B) :- encode(C,F,T,A,B,S).
scale(encode(C,F,T,A,B,S), S) :- encode(C,F,T,A,B,S).

% field projection
fields(F) :- fieldtype(F,_).

% visualization type
is_q :- encode(x,_,q), not encode(y).
is_q :- encode(y,_,q), not encode(x).

is_o_o_or_n_n :- encode(x,_,o), encode(y,_,o).
is_o_o_or_n_n :- encode(x,_,n), encode(y,_,n).

is_q_n :- encode(x,_,q), encode(y,_,n).
is_q_n :- encode(y,_,q), encode(x,_,n).

is_q_o :- encode(x,_,q), encode(y,_,o).
is_q_o :- encode(y,_,q), encode(x,_,o).

is_q_q :- encode(y,_,q), encode(x,_,q).

% orientation for bars and ticks
orientation(horizontal) :- mark(bar;tick), encode(x,_,(o;n)).
orientation(vertical) :- mark(bar;tick), encode(y,_,(o;n)).

% encoding is a dimension
dimension(E) :- type(E,(n;o)).
dimension(E) :- bin(E,B), B != null.

% ====== Constraints ======

% === Within encodings ===

% primitive type has to support data type
:- encode(_,F,q), fieldtype(F,string).
:- encode(_,F,q), fieldtype(F,boolean).

% can only bin quantitative
% :- encode(_,_,T,_,B), B != null, T != q.
:- type(E,T), bin(E,B), B != null, T != q.

% do not use scale zero with dimension
% :- dimension(encode(C,F,T,A,B,zero)).
:- scale(E,zero), dimension(E).

% do not use log scale with dimension
%:- dimension(encode(C,F,T,A,B,log)).
:- scale(E,log), dimension(E).

% cannot bin and aggregate
% :- encode(_,_,_,A,B), A != null, B != null.
:- bin(E,B), aggregate(E,A), A != null, B != null.

% mean and sum only works for quantitative
:- encode(_,_,T,(sum;mean),_), T != q.

% min, max, and median only work for ordinal and quantitative
:- encode(_,_,T,(min;max;median),_), T != q, T != o.

% count field (*) requires count (and vice versa) (and field has to be quantitative)
:- encode(_,F,_,count,_,_), F != row.
:- encode(_,row,_,A,_,_), A != count.
:- encode(_,_,T,count,_,_), T != q.

% shape requires dimension
:- encode(shape), not dimension(encode(shape,_,_,_,_,_)).

% size or text require measure
:- dimension(encode((size;text),_,_,_,_,_)).

% categorical color channel should not have too high cardinality
:- encode(color,F,_), cardinality(F,C), C > 20.

% shape channel should not have too high cardinality
:- encode(shape,F,_), cardinality(F,C), C > 6.

% aggregate implies quantitative
:- encode(_,_,T,A,_), A != null, T != q.

% === Across encodings and between encodings and marks ===

% text mark requires text channel
:- mark(text), not encode(text).
% and row or column
:- mark(text), not encode(row), not encode(column).

% point, tick, and bar require x or y channel
:- mark(point;tick;bar), not encode(x), not encode(y).

% line and area require x and y channel
:- mark(line;area), not encode(x).
:- mark(line;area), not encode(y).

% bar and tick requires quantitative (x or y)
:- mark(bar;tick), not encode(x,_,q), not encode(y,_,q).
% and optional ordinal/nominal (x or y); not two quantitative
:- mark(bar;tick), encode(x,_,q), encode(y,_,q).

% bar mark requires scale to start at zero
:- mark(bar), encode((x;y),_,q,_,_,S), S != zero.

% shape channel requires point mark
:- encode(shape), not mark(bar).

% size only works with some marks
:- encode(size), not mark(point), not mark(rule), not mark(text), not mark(line).

% bar and tick should not use size
:~ mark(bar;tick), encode(size). [1@1]

% supported encoding channels
:- mark(point), encode(text).
:- mark(tick;bar), encode((shape;size;detail;text)).
:- mark(line;area), encode((shape;size;text)).
:- mark(text), encode((x;y;shape;size;detail)).

% only use supported mark types
:- is_q, not mark(tick), not mark(point), not mark(text).
:- is_o_o_or_n_n, not mark(point), not mark(text).
:- is_q_n, not mark(bar), not mark(point), not mark(text).
:- is_q_o, not mark(line), not mark(bar), not mark(point), not mark(text).
:- is_q_q, not mark(point), not mark(text).

% supported channels

supported_channel(q,(x;y)).
supported_channel(q,size).
supported_channel(q,color).
supported_channel(q,text).

supported_channel((o;n),(x;y)).
supported_channel((o;n),(column;row)).
supported_channel((o;n),(column;row)).
supported_channel((o;n),color).

supported_channel(o,size).
supported_channel(n,shape).

% can only use supported channels
:- encode(C,_,T), not supported_channel(T,C).

% ====== Preferences ======

% channel preferences

% channel weight
#const cw = 1.

:~ encode(size,_,q). [1*cw@1]
:~ encode(color,_,q). [2*cw@1]
:~ encode(text,_,q). [3*cw@1]

:~ encode(facet,_,(o;n)). [1*cw@1]
:~ encode(color,_,(o;n)). [2*cw@1]

:~ encode(size,_,o). [3*cw@1]
:~ encode(shape,_,n). [3*cw@1]


% prefer quantitative > ordinal > nominal

% type weight
#const tw = 1.

:~ encode(_,_,o). [1*tw@1]
:~ encode(_,_,n). [2*tw@1]

% prefer to use raw (no aggregation)

% aggregation weight
#const aw = 1.

:~ encode(_,_,_,A,_), A != null. [aw@1]

% ====== Output ======
#show mark/1.
#show encode/6.
