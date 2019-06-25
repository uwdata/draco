

% rows
data_fact(rows,size,high) :- num_rows(S), S >= 1000.

data_fact(rows,size,medium) :- num_rows(S), S >= 100, not data_fact(rows,size,high).

data_fact(rows,size,low) :- num_rows(S), S >= 50, not data_fact(rows,size,medium).

data_fact(rows,size,very_low) :- num_rows(S), S >= 10, not data_fact(rows,size,low).

data_fact(rows,size,very_very_low) :- num_rows(S), not data_fact(rows,size,very_low).

% fields
data_fact(field,min_sign,negative,F) :- extent(F,MIN,_), MIN < 0.

data_fact(field,min_sign,zero,F) :- extent(F,MIN,_), MIN = 0.

data_fact(field,min_sign,positive,F) :- extent(F,MIN,_), MIN > 0.

data_fact(field,max_sign,negative,F) :- extent(F,_,MAX), MAX < 0.

data_fact(field,max_sign,zero,F) :- extent(F,_,MAX), MAX = 0.

data_fact(field,max_sign,positive,F) :- extent(F,_,MAX), MAX > 0.

data_fact(field,min_minus_max_gt_min_or_max_minus_zero,F) :- extent(F,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX.

data_fact(field,extent_includes_zero,F) :- data_fact(field,min_sign,(negative;zero),F), data_fact(field,max_sign,(zero;positive),F).

% overlap
data_fact(overlap,definitely,(F1,F2)) :- cardinality(F1,C1), cardinality(F2,C2), num_rows(S), S > C1 * C2.

data_fact(overlap,definitely_not,(F1,F2)) :- cardinality(F1,C1), cardinality(F2,C2), num_rows(S), C1 = S, C2 = S.

