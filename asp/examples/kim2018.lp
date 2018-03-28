% test with `clingo asp/_kim2018.lp asp/examples/kim2018.lp --opt-mode=optN --quiet=1 --project`

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
mark(point).

encoding(enc_n).
:- not type(enc_n,nominal).
:- not field(enc_n,n).

encoding(enc_q1).
:- not type(enc_q1,quantitative).
:- not field(enc_q1,q1).

encoding(enc_q2).
:- not type(enc_q2,quantitative).
:- not field(enc_q2,q2).

% ====== Task constraints ======
task(summary).
