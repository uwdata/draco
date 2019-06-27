#const max_fields = 10.
0 { field_id(1..max_fields) } max_fields.


1 = { num_rows(S): S = (5; 10; 50; 100; 1000) }.
1 = { fieldtype(F,T): fieldtype_type(T) } :- field_id(F).

1 = { cardinality(F,C): C = (2;5;9;21;31;101;10;20;100;1000) } :- field(F).
1 = { extent(F,MIN,MAX): MIN = (-100;-1;0;1;100), MAX = (-50;-1;0;1;100)} :- field(F).

#show num_rows/1.
#show fieldtype/2.
#show cardinality/2.
#show extent/3.
