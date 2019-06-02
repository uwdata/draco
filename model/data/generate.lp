% fields
#const max_fields = 10.
0 { field_id(1..max_fields) } max_fields.
1 = { fieldtype(F,T): fieldtype_type(T) } :- field_id(F).
1 = { field(F) } :- fieldtype(F,_).

% rows
1 = { data_fact(NAME,true): data_fact_type(rows,NAME) }.

% cardinality
1 = { data_fact(NAME,F): data_fact_type(cardinality,NAME) } :- field(F).

% fields
0 { data_fact(NAME,F) : data_fact_type(field,NAME) } 1 :- field(F).

% multi
0 { data_fact(NAME,(F1,F2)): data_fact_type(multi_field,NAME) } 1 :- field(F1), field(F2), F1 != F2.
