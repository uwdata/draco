% from input
fieldtype(F,T) :- fieldtype(F,T).
field(F) :- fieldtype(F,_).

% rows
data_fact(rows_high,true) :- num_rows(S), S >= 1000.

data_fact(rows_medium,true) :- num_rows(S), S >= 100, not data_fact(rows_high,true).

data_fact(rows_low,true) :- num_rows(S), S >= 50, not data_fact(rows_medium,true).

data_fact(rows_very_low,true) :- num_rows(S), S >= 10, not data_fact(rows_low,true).

% fields
data_fact(negative_min,F) :- extent(F,MIN,_), MIN < 0.

data_fact(negative_or_zero_min,F) :- extent(F,MIN,_), MIN <= 0, not data_fact(negative_min,F).

data_fact(cardinality_gt_8,F) :- cardinality(F,C), C > 8.

data_fact(cardinality_gt_20,F) :- cardinality(F,C), C > 20.

data_fact(cardinality_gt_30,F) :- cardinality(F,C), C > 30.

data_fact(cardinality_gt_100,F) :- cardinality(F,C), C > 100.

data_fact(min_minus_max_gt_min_or_max_minus_zero,F) :- extent(F,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX.

data_fact(extent_includes_zero,F) :- extent(F,MIN,MAX), MIN < 0, MAX > 0.

data_fact(cardinality_very_high,F) :- cardinality(F,C), C >= 1000.

data_fact(cardinality_high,F) :- cardinality(F,C), C >= 100, not data_fact(cardinality_very_high,F).

data_fact(cardinality_medium,F) :- cardinality(F,C), C >= 20, not data_fact(cardinality_high,F).

data_fact(cardinality_low,F) :- cardinality(F,C), C >= 10, not data_fact(cardinality_medium, F).

data_fact(cardinality_very_low,F) :- cardinality(F,C), C >= 5, not data_fact(cardinality_low,F).

data_fact(cardinality_very_very_low,F) :- cardinality(F,C), not data_fact(cardinality_very_low,F).

% overlap
data_fact(definitely_overlap_fields,(F1,F2)) :- cardinality(F1,C1), cardinality(F2,C2), num_rows(S), S > C1 * C2.

data_fact(definitely_not_overlap_fields,(F1,F2)) :- cardinality(F1,C1), cardinality(F2,C2), num_rows(S), C1 = S, C2 = S.

