:- data_fact(negative_min,F), not data_fact(negative_or_zero_min,F).
:- data_fact(cardinality_gt_20,F), not data_fact(cardinality_gt_8,F).
:- data_fact(definitely_overlap_fields,(F1,F2)), data_fact(definitely_not_overlap_fields,(F1,F2)).
