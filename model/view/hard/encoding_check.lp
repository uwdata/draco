% @constraint Primitive type has to support data type.
encoding_check(fieldtype_valid,V,E) :- type(V,E,quantitative), field(V,E,F), fieldtype(F,(string;boolean)).
encoding_check(fieldtype_valid,V,E) :- type(V,E,temporal), field(V,E,F), not fieldtype(F,date).

% @constraint Can only bin quantitative or ordinal.
encoding_check(bin_quant_or_ord,V,E) :- type(V,E,T), bin(V,E,true), T != quantitative, T != ordinal.

% @constraint Cannot bin and aggregate.
encoding_check(bin_and_aggregate,V,E) :- aggregate(V,E,_), bin(V,E,true).

% @constraint Oridnal only supports min, max, and median.
encoding_check(aggregate_o_valid,V,E) :- aggregate(V,E,A), type(V,E,ordinal), A != min, A != max, A != median.

% @constraint Temporal only supports min and max.
encoding_check(aggregate_t_valid,V,E) :- aggregate(V,E,A), type(V,E,temporal), A != min, A != max.

% @constraint Cannot aggregate nominal.
encoding_check(aggregate_nominal,V,E) :- aggregate(V,E,_), type(V,E,nominal).

% @constraint Detail cannot be aggregated.
encoding_check(aggregate_detail,V,E) :- channel(V,E,detail), aggregate(V,E,_).

% @constraint Count has to be quantitative and not use a field.
encoding_check(count_q_without_field,V,E) :- aggregate(V,E,count), field(V,E,_).
encoding_check(count_q_without_field,V,E) :- aggregate(V,E,count), not type(V,E,quantitative).

% @constraint Shape requires discrete and not ordered (nominal). Using ordinal would't make a difference in Vega-Lite.
encoding_check(shape_discrete_non_ordered,V,E) :- channel(V,E,shape), not type(V,E,nominal).

% @constraint Detail requires nominal.
encoding_check(detail_non_ordered,V,E) :- channel(V,E,detail), not type(V,E,nominal).

% @constraint Size implies order so nominal is misleading.
encoding_check(size_nominal,V,E) :- channel(V,E,size), type(V,E,nominal).

% % @constraint Do not use size when data is negative as size implies that data is positive.
encoding_check(size_negative,V,E) :- channel(V,E,size), field(V,E,F), data_fact(field,min_sign,negative,F).

% === Across encodings and between encodings and marks ===

% @constraint Cannot use single channels twice.
encoding_check(repeat_channel,V,true) :- view(V), channel_definition(single,C), 2 { channel(V,_,C) }.

% @constraint There has to be at least one encoding. Otherwise, the view doesn't show anything.
encoding_check(no_encodings,V,true) :- view(V), not encoding(V,_).

% @constraint Row and column require discrete.
encoding_check(row_or_column_c,V,true) :- channel_fact(continuous,V,(row;column)).

% @constraint Don't use row without y. Just using y is simpler.
encoding_check(row_no_y,V,true) :- channel(V,_,row), not channel(V,_,y).

% @constraint Don't use column without x. Just using x is simpler.
encoding_check(column_no_x,V,true) :- channel(V,_,column), not channel(V,_,x).

% @constraint All encodings (if they have a channel) require field except if we have a count aggregate.
encoding_check(encoding_no_field_and_not_count,V,E) :- not field(V,E,_), not aggregate(V,E,count), encoding(V,E).

% @constraint Count should not have a field. Having a field doesn't make a difference.
encoding_check(count_with_field,V,E) :- aggregate(V,E,count), field(V,E,_).

% @constraint Don't use count twice.
encoding_check(count_twice,V,true) :- view(V), { aggregate(V,_,count) } = 2.
