% test with `clingo asp/_younghoon.lp examples/example_younghoon.lp --opt-mode=optN --quiet=1 --project`

% ====== Data definitions ======
num_rows(30).

fieldtype(n,string).
cardinality(n,10).
interesting(n).

fieldtype(q1,number).
cardinality(q1,30).
interesting(q1).
entropy(q1,38).

fieldtype(q2,number).
cardinality(q2,30).
entropy(q2,39).

% ====== Query constraints ======

task(summary).

mark(point).

encoding(enc_n).
type(enc_n,nominal).
field(enc_n,n).

encoding(enc_q1).
type(enc_q1,quantitative).
field(enc_q1,q1).

encoding(enc_q2).
type(enc_q2,quantitative).
field(enc_q2,q2).
