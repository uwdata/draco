% ====== Data definitions for tests ======

num_rows(100).

fieldtype(n1,string).
cardinality(n1,20).
entropy(n1,8).  % Entropy is in 0.1 units because ASP only supports integers.

fieldtype(n2,string).
cardinality(n2,3).
entropy(n2,12).

fieldtype(o1,string).
cardinality(o2,7).
entropy(o2,1).

fieldtype(q1,number).
cardinality(q1,12).
entropy(q1,21).
extent(q1,0,10).

fieldtype(q2,number).
cardinality(q2,100).
entropy(q2,8).
extent(q2,10,30).
