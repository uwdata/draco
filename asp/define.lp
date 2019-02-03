% ====== Definitions ======

% Types of marks to encode data.
marktype(point;bar;line;area;text;tick;rect).
% High level data types: quantitative, ordinal, nominal, temporal.
type(quantitative;ordinal;nominal;temporal).
% Basic types of the data.
primitive_type(string;number;boolean;datetime).
% Supported aggregation functions.
aggregate_op(count;mean;median;min;max;stdev;sum).
summative_aggregate_op(count;sum).
% Numbers of bins that can be recommended; any natural number is allowed.
binning(10;25;200).

% Encoding channels.
single_channel(x;y;color;size;shape;text;row;column).
multi_channel(detail).
channel(C) :- single_channel(C).
channel(C) :- multi_channel(C).
non_positional(color;size;shape;text;detail).

% Possible tasks.
tasks(value;summary).

% Possible stackings.
stacking(zero;normalize).

% ====== Helpers ======

discrete(V,E) :- type(V,E,(nominal;ordinal)).
discrete(V,E) :- bin(V,E,_).
continuous(V,E) :- encoding(V,E), not discrete(V,E).

channel_discrete(V,C) :- discrete(V,E), channel(V,E,C).
channel_continuous(V,C) :- continuous(V,E), channel(V,E,C).

ordered(E) :- type(V,E,(ordinal;quantitative)).

% Fields
field(F) :- fieldtype(F,_).

% Stacking is applied to the continuous x or y.
stack(V,EC,S) :- channel(V,EC,(x;y)), channel(V,ED,(x;y)), continuous(V,EC), discrete(V,ED), stack(V,S).
% X and y are continuous.
stack(E,S) :- channel_continuous(V,x), channel(V,E,y), continuous(V,E), stack(V,S).

stack(V,S) :- encoding(V,E), stack(E,S).

% Data properties
enc_cardinality(V,E,C) :- field(V,E,F), cardinality(F,C).
enc_entropy(V,E,EN) :- field(V,E,F), entropy(F,EN).
enc_interesting(V,E) :- field(V,E,F), interesting(F).
enc_extent(V,E,MIN,MAX) :- field(V,E,F), extent(F,MIN,MAX).

% Cardinality of discrete field. A binned field has the cadinality of its field.
discrete_cardinality(V,E,CE) :- discrete(V,E), enc_cardinality(V,E,CE), channel(V,E,C), not bin(V,E,_).
discrete_cardinality(V,E,CB) :- channel(V,E,C), bin(V,E,CB).

% Define a fake soft/2 for all soft/1.
soft(F,V,_placeholder) :- soft(F,V).

% Silence warnings about properties never appearing in head.
entropy(0,0) :- #false.
interesting(0) :- #false.
extent(0,0,0) :- #false.
soft(0) :- #false.
task(0,value) :- #false.
task(0,summary) :- #false.
data(0) :- #false.
base(0) :- #false.

% == Chart Types ==

% Continuous by continuous.
is_c_c(V) :- channel_continuous(V,x), channel_continuous(V,y).

% Continuous by discrete (or continuous only).
is_c_d(V) :- channel_continuous(V,x), not channel_continuous(V,y).
is_c_d(V) :- channel_continuous(V,y), not channel_continuous(V,x).

% Discrete by discrete.
is_d_d(V) :- channel_discrete(V,x), channel_discrete(V,y).

% == Overlap ==

% The continuous variable is a measure (it is aggregated) and all other channels are .aggregated, or we use stack -> no overlap
non_pos_unaggregated(V) :- channel(V,E,C), non_positional(C), not aggregate(V,E,_).
no_overlap(V) :- is_c_d(V), continuous(V,E), channel(V,E,(x;y)), aggregate(V,E,_), not non_pos_unaggregated(V).
no_overlap(V) :- is_c_d(V), stack(V,_).

% the size of the discrete positional encoding
discrete_size(V,S) :- is_c_d(V), x_y_cardinality(V,_,S).
discrete_size(V,1) :- is_c_d(V), channel_continuous(V,x), not channel(V,_,y).
discrete_size(V,1) :- is_c_d(V), channel_continuous(V,y), not channel(V,_,x).

% Data size is as small as discrete dimension -> no overlap.
no_overlap(V) :- is_c_d(V), num_rows(S), discrete_size(V,S).

% We definitely overlap if the data size > discrete size.
overlap(V) :- is_c_d(V), not no_overlap(V), num_rows(S1), discrete_size(V,S2), S1 > S2.

% helpers to go from quadratic to linear number of grounding
x_y_cardinality(V,x,S) :- channel(V,E,x), discrete_cardinality(V,E,S).
x_y_cardinality(V,y,S) :- channel(V,E,y), discrete_cardinality(V,E,S).

% No overlap if all other dimensions are aggregated.
discrete_size(V,S) :- is_d_d(V), x_y_cardinality(V,x,SX), x_y_cardinality(V,y,SY), S = SX*SY.
no_overlap(V) :- is_d_d(V), not non_pos_unaggregated(V).
no_overlap(V) :- is_d_d(V), num_rows(S1), discrete_size(V,S2), S1 <= S2.  % This cannot guarantee no overlap.

% We can guarantee overlap using this rule unless we are using row / column.
row_col(V) :- channel(V,_,(row;column)).
overlap(V) :- is_d_d(V), channel(V,E,C), not row_col(V), not no_overlap(V), num_rows(S1), discrete_size(V,S2), S1 > S2.

% == Orientation ==

% Orientation tells us which one is the dependent and independent variable.

orientation(V,vertical) :- mark(V,(bar;tick;area;line)), channel_discrete(V,x).
orientation(V,vertical) :- mark(V,(area;line)), channel_continuous(V,x), channel_continuous(V,y).

orientation(V,horizontal) :- mark(V,(bar;tick;area;line)), channel_discrete(V,y).
