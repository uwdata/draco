% ====== Definitions ======

% types of marks to encode data
marktype(point;bar;line;area;rule;text;tick;rect).
% high level data types: quantitative, ordinal, nominal, temporal
type(quantitative;ordinal;nominal;temporal).
% basic types of the data
primitive_type(string;number;boolean;date).
% supported aggregation functions
aggregate_op(count;mean;median;min;max;stdev;sum).
summative_aggregate_op(count;sum).
% numbers of bins that can be recommended; any natural number is allowed
binning(5;10;20;200).

% encoding channels
single_channel(x;y;color;opacity;size;shape;text;row;column).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).
non_positional(color;opacity;size;shape;text;detail).

% possible tasks
tasks(value;summary).

% possible stackings
stacking(zero;normalize).

% ====== Helpers ======

discrete(E) :- type(E,(nominal;ordinal)).
discrete(E) :- bin(E,_).
continuous(E) :- encoding(E), not discrete(E).

channel_discrete(C) :- discrete(E), channel(E,C).
channel_continuous(C) :- continuous(E), channel(E,C).

ordered(E) :- type(E,(ordinal;quantitative)).

% fields
field(F) :- fieldtype(F,_).

% stacking is applied to the continuous x or y
stack(E,S) :- continuous(E), stack(S).

% data properties
enc_cardinality(E,C) :- field(E,F), cardinality(F,C).
enc_entropy(E,EN) :- field(E,F), entropy(F,EN).
enc_interesting(E) :- field(E,F), interesting(F).
enc_extent(E,MIN,MAX) :- field(E,F), extent(F,MIN,MAX).

% define a fake feature_term/2 for all feature_term/1.
feature_term(F,_placeholder) :- feature_term(F).

% silence warnings about properties never appearing in head
_true(false).
entropy(0,0) :- _true(true).
interesting(0) :- _true(true).
extent(0,0,0) :- _true(true).
