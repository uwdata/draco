#const max_fields = 4.
field_id(1..max_fields).

% a field type
1 = { fieldtype(F,T): fieldtype_type(T) } :- field_id(F).

% cardinality of fields
1 = { cardinality(F,C): C = (2;3;10;20;50) } :- field(F).

% extent for numeric fields
1 = { extent(F,MIN,MAX): MIN = (-100;-1;0;1), MAX = (-1;0;1;100), MIN < MAX } :- field(F), fieldtype(F,(number;integer)).
% if integer, cardinality must be < extent.
:- fieldtype(F,integer), cardinality(F,C), extent(F,MIN,MAX), C > MAX - MIN + 1.
% boolean cardinality must be 2.
:- fieldtype(F,boolean), cardinality(F,C), C > 2.

num_rows_up_to_field_id(S,1) :- field_id(1), cardinality(1,S).
num_rows_up_to_field_id(S,ID) :- field_id(ID), num_rows_up_to_field_id(PREV,ID - 1), cardinality(ID,C), S = PREV * C.
num_rows(S) :- N = #max { ID: field_id(ID) }, num_rows_up_to_field_id(S,N).

#show num_rows/1.
#show num_rows_up_to_field_id/2.
#show fieldtype/2.
#show cardinality/2.
#show extent/3.
