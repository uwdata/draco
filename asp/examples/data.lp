% ====== Data definitions for tests ======

data_size(100).

fieldtype(s1,string).
cardinality(s1,10).
entropy(s1,8).  % entropy is in 0.1 units because asp only supports integers

fieldtype(s2,string).
cardinality(s2,3).
entropy(s1,12).

fieldtype(n1,number).
cardinality(n1,12).
entropy(n1,21).
min(n1,0).
max(n1,10).

fieldtype(n2,number).
cardinality(n2,100).
entropy(n2,8).
min(n2,10).
max(n2,11).
