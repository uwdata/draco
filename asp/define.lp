% ====== Definitions ======

% types of marks to encode data
marktype(point;bar;line;area;rule;text;tick;rect).
% high level data types: quantitative, ordinal, nominal, temporal
type(q;o;n;t).
% basic types of the data
primitive_type(string;number;integer;boolean;date).
% supported aggregation functions
aggregate(count;mean;median;min;max).
% possible numebrs of bins
bin(3;5;10;100;200).

% encoding channels
single_channel(x;y;color;opacity;size;shape;text).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).
non_positional(color;opacity;size;shape;text;detail).

field(F) :- fieldtype(F,_).

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
