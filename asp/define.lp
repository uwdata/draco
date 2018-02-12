% ====== Definitions ======

% types of marks to encode data
marktype(point;bar;line;area;rule;text;tick;rect).
% high level data types: quantitative, ordinal, nominal, temporal
type(quantitative;ordinal;nominal;temporal).
% basic types of the data
primitive_type(string;number;integer;boolean;date).
% supported aggregation functions
aggregate(count;mean;median;min;max).
% possible numbers of bins
bin(3;5;10;100;200).

% encoding channels
single_channel(x;y;color;opacity;size;shape;text;row;column).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).
non_positional(color;opacity;size;shape;text;detail).

field(F) :- fieldtype(F,_).

% ====== Helpers ======

discrete(E) :- type(E,(nominal;ordinal)), not aggregate(E,_).
discrete(E) :- bin(E,_).
continuous(E) :- encoding(E), not discrete(E).

channel_discrete(C) :- discrete(E), channel(E,C).
channel_continuous(C) :- continuous(E), channel(E,C).

% orientation for bars and ticks
orientation(horizontal) :- mark(bar;tick), channel_discrete(x).
orientation(vertical) :- mark(bar;tick), channel_discrete(y).

cardinality(E,C) :- field(E,F), cardinality(F,C).
entropy(E,EN) :- field(E,F), entropy(F,EN).
