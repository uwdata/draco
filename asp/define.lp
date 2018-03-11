% ====== Definitions ======

% types of marks to encode data
marktype(point;bar;line;area;text;tick;rect).
% high level data types: quantitative, ordinal, nominal, temporal
type(quantitative;ordinal;nominal;temporal).
% basic types of the data
primitive_type(string;number;boolean;datetime).
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
stack(EC,S) :- channel(EC,(x;y)), channel(ED,(x;y)), continuous(EC), discrete(ED), stack(S).
% x and y are continuous
stack(E,S) :- channel_continuous(x), channel(E,y), continuous(E), stack(S).

stack(S) :- stack(_,S).

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

% == Chart Types ==

% continuous by continuous
is_c_c :- channel_continuous(x), channel_continuous(y).

% continuous by discrete (or continuous only)
is_c_d :- channel_continuous(x), not channel_continuous(y).
is_c_d :- channel_continuous(y), not channel_continuous(x).

% discrete by discrete
is_d_d :- channel_discrete(x), channel_discrete(y).

% == Overlap ==

no_verlap :- is_c_c, aggregate(E,_), channel(E,y).
overlap :- is_c_c, not no_overlap, channel(EX,x), enc_cardinality(EX,CX), data_size(S), S > CX.

% the continuous variable is a measure (it is aggregated) and all other channels are aggregated, or we use stack -> no overlap
non_pos_unaggregated :- channel(E,C), non_positional(C), not aggregate(E,_).
no_overlap :- is_c_d, continuous(E), channel(E,(x;y)), aggregate(E,_), not non_pos_unaggregated.
no_overlap :- is_c_d, stack(_).

discrete_size(S) :- is_c_d, channel(E,(x;y)), discrete(E), enc_cardinality(E,S).
discrete_size(1) :-  is_c_d, channel_continuous(x), not channel(_,y).
discrete_size(1) :-  is_c_d, channel_continuous(y), not channel(_,x).

% data size is as small as discrete dimension -> no overlap
no_overlap :- is_c_d, data_size(S), discrete_size(S).

% we definitely overlap if the data size > discrete size
overlap :- is_c_d, not no_overlap, data_size(S1), discrete_size(S2), S1 > S2.

% no overlap if all other dimensions are aggregated
discrete_size(S) :- is_d_d, channel(EX,x), channel(EY,y), enc_cardinality(EX,SX), enc_cardinality(EY,SY), S = SX*SY.
no_overlap :- is_d_d, not non_pos_unaggregated.
no_overlap :- is_d_d, data_size(S1), discrete_size(S2), S1 <= S2.

overlap :- is_d_d, not no_overlap, data_size(S1), discrete_size(S2), S1 > S2.
