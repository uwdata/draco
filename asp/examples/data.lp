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

fieldtype(n2,number).
cardinality(n2,100).
entropy(n2,8).
