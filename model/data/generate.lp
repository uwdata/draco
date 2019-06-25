#const max_fields = 10.
0 { field_id(1..max_fields) } max_fields.


1 = { num_rows(S): S = (5; 10; 50; 100; 1000) }.
1 = { fieldtype(F,T): fieldtype_type(T) } :- field_id(F).

1 = { cardinality(F,C): C = (2;5;9;21;31;101;10;20;100;1000) } :- field(F).
1 = { extent(F,MIN,MAX): MIN = (-100;-1;0;1;100), MAX = (-50;-1;0;1;100)} :- field(F).

% 1 = { data_fact(rows,size,T): data_fact_type(rows,size,T) }.

% 1 = { data_fact(field,min_sign,T,F): data_fact_type(field,min_sign,T) } :- field(F).
% 1 = { data_fact(field,max_sign,T,F): data_fact_type(field,max_sign,T) } :- field(F).
% :- data_fact(field,min_sign,zero,F), data_fact(field,max_sign,negative,F).
% :- data_fact(field,min_sign,positive,F), data_fact(field,max_sign,(negative;zero),F).


% 1 = { data_fact(field,cardinality_greater_than,N,F): data_fact_type(field,cardinality_greater_than,N) } :- field(F).
% data_fact(field,cardinality_greater_than,N,F) :- data_fact_type(field,cardinality_greater_than,N), data_fact(field,cardinality_greater_than,M,F), N > M.

% 0 { data_fact(field,min_minus_max_gt_min_or_max_max_minus_zero,F) } 1 :- field(F).

% 1 = { data_fact(field,cardinality,T,F): data_fact_type(field,cardinality,T) } :- field(F).

% 0 { data_fact(overlap,definitely,(F1,F2)) } 1 :- field(F1), field(F2).
% 0 { data_fact(overlap,definitely_not,(F1,F2)) } 1 :- field(F1), field(F2).
% :- data_fact(overlap,definitely,(F1,F2)), data_fact(overlap,definitely_not,(F1,F2)).
% :- data_fact(overlap,definitely,(F1,F2)), data_fact(rows,size,T), data_fact(field,cardinality,T,F1), data_fact(field,cardinality,T,F2), 

