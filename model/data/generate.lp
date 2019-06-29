#const max_fields = 4.
0 { field_id(1..max_fields) } max_fields.


1 = { num_rows(S): S = (10; 50; 100; 1000) }.
1 = { fieldtype(F,T): fieldtype_type(T) } :- field_id(F).

1 = { cardinality(F,C): C = (1;2;5;9;21;31;101;100;1000) } :- field(F).
1 = { extent(F,MIN,MAX): MIN = (-100;-1;0;1;100), MAX = (-100;-1;0;1;100)} :- field(F).

:- fieldtype(F,MIN,MAX), MAX < MIN.
:- fieldtype(F,integer), cardinality(F,C), extent(F,MIN,MAX), C > MAX - MIN + 1.
:- fieldtype(F,boolean), cardinality(F,C), C > 2.
:- fieldtype(F,_), cardianlity(F, C), C > 1, extent(F,MIN,MAX), MAX - MIN = 0.

#show num_rows/1.
#show fieldtype/2.
#show cardinality/2.
#show extent/3.
