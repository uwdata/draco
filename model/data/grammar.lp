fieldtype_type(number;string;integer;boolean;date).

data_fact_type(rows,size,(very_low;low;medium;high)).

data_fact_type(field,min_sign,(negative;zero;positive)).

data_fact_type(field,max_sign,(negative;zero;positive)).

data_fact_type(field,cardinality_greater_than,(8;20;30;100)).

data_fact_type(field,min_minus_max_gt_min_or_max_minus_zero).

data_fact_type(field,extent_includes_zero).

data_fact_type(field,cardinality,(very_very_low;very_low;low;medium;high;very_high)).

data_fact_type(overlap,definitely).

data_fact_type(overlap,definitely_not).
