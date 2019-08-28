fieldtype(n,string).
fieldtype(q1,number).
fieldtype(q2,number).

1 = { cardinality(F,C): C = (3;10;20;30) } :- field(F).
:- cardinality(F,(10;20)), fieldtype(F,string).
:- cardinality(F,30), fieldtype(F,number).

1 = { entropy(F,E): E = (low;high) } :- field(F).
:- entropy(F,low), fieldtype(F,string).

1 = { interesting(F,T): T = (true;false) } :- field(F).

num_rows(R) :- cardinality(n,C1), cardinality(q1,C2), cardinality(q2,C3), R = C1 * C2 * C3.

#show num_rows/1.
#show fieldtype/2.
#show cardinality/2.
#show entropy/2.
