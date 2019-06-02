fieldtype_type(number;string).

% rows
data_fact_type(rows,rows_high).

data_fact_type(rows,rows_medium).

data_fact_type(rows,rows_low).

data_fact_type(rows,rows_very_low).

% fields
data_fact_type(field,negative_min).

data_fact_type(field,negative_or_zero_min).

data_fact_type(field,cardinality_gt_8).

data_fact_type(field,cardinality_gt_20).

data_fact_type(field,min_minus_max_gt_min_or_max_minus_zero).

data_fact_type(field,extent_includes_zero).

% cardinality
data_fact_type(cardinality,cardinality_very_high).

data_fact_type(cardinality,cardinality_high).

data_fact_type(cardinality,cardinality_medium).

data_fact_type(cardinality,cardinality_low).

data_fact_type(cardinality,cardinality_very_low).

data_fact_type(cardinality,cardinality_very_very_low).

% overlap
data_fact_type(multi_field,definitely_overlap_fields).

data_fact_type(multi_field,definitely_not_overlap_fields).

