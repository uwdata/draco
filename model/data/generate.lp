#const max_fields = 3.
field_id(1..max_fields).

1 = { num_rows(S): S = (20;50;100) }.
:- num_rows(S), cardinality(F,C), C < S.

% a field type
1 = { fieldtype(F,T): fieldtype_type(T) } :- field_id(F).

% cardinality of fields
1 = { cardinality(F,C): C = (3;10;20) } :- fieldtype(F,string).
cardinality(F,2) :- fieldtype(F,boolean).
cardinality(F,S) :- num_rows(S), fieldtype(F,number).


% extent for numeric fields
1 = { extent(F,MIN,MAX): MIN = (-100;-1;0;1), MAX = (-1;0;1;100), MIN < MAX } :- field(F), fieldtype(F,number).

#show num_rows/1.
#show num_rows_up_to_field_id/2.
#show fieldtype/2.
#show cardinality/2.
#show extent/3.
