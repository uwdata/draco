% ====== Definitions ======

marktype(point;bar;line;area;rule;symbol;text;tick).
type(q;o;n).
primitive_type(string;number;boolean).
aggregate(null;count;mean;median;min;max).
binning(null;3;5;10;100;200).
scale(null;zero;log).

% channels
single_channel(x;y;color;size;shape;text).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).

% ====== Data definitions ======

% special field for count
fieldtype(one,row).

% ====== Generate ======

% pick one marktype
{ mark(M) : marktype(M) } = 1.

% we can encode fields with channels
0 { encode(C,F,T,A,B,S) : field(F), type(T), aggregate(A), binning(B), scale(S) } 1 :- single_channel(C).
{ encode(C,F,T,A,B,S) : field(F), type(T), aggregate(A), binning(B), scale(S) } :- multi_channel(C).

% ====== Helpers ======

% projections of encoding
encode(C,F,T,A,B) :- encode(C,F,T,A,B,_).
encode(C,F,T) :- encode(C,F,T,_,_,_).
encode(C) :- encode(C,_,_,_,_,_).

% field projection
field(F) :- fieldtype(F,_).

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
dimension(encode(C,F,T,A,B,S)) :- encode(C,F,T,A,B,S), T = n.
dimension(encode(C,F,T,A,B,S)) :- encode(C,F,T,A,B,S), T = o.
dimension(encode(C,F,T,A,B,S)) :- encode(C,F,T,A,B,S), B != null.

% ====== Constraints ======

% === Within encodings === 

% primitive type has to support data type
:- encode(_,F,q), fieldtype(F,string).
:- encode(_,F,q), fieldtype(F,boolean).

% can only bin quantitative
:- encode(_,_,T,_,B), B != null, T != q.

% do not use scale zero with dimension
:- dimension(encode(C,F,T,A,B,zero)).

% do not use log scale with dimension
:- dimension(encode(C,F,T,A,B,log)).

% cannot bin and aggregate
:- encode(_,_,_,A,B), A != null, B != null.

% mean and sum only works for quantitative
:- encode(_,_,T,(sum;mean),_), T != q.

% min, max, and median only work for ordinal and quantitative
:- encode(_,_,T,(min;max;median),_), T != q, T != o.

% count field (*) requires count (and vice versa) (and field has to be quantitative)
:- encode(_,F,_,count,_,_), F != row.
:- encode(_,row,_,A,_,_), A != count.
:- encode(_,_,T,count,_,_), T != q.

% === Across encodings ===

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

% don't use aggregation if possible

% aggregation weight
#const aw = 1.

:~ encode(_,_,_,A,_), A != null. [aw@1]

% ====== Output ======
#show mark/1.
#show encode/6.
