% test with `clingo asp/_apt.lp asp/examples/apt.lp --opt-mode=optN --quiet=1 --project -c max_extra_encs=0`

% ====== Data definitions ======
num_rows(20).

fieldtype(a,number).
cardinality(a,20).

fieldtype(b,number).
cardinality(b,20).

fieldtype(c,string).
cardinality(c,4).

fieldtype(d,number).
cardinality(d,6).

% ====== Query constraints ======
mark(point).

encoding(e0).
priority(e0,4).
:- not type(e0,quantitative).
:- not field(e0,a).

encoding(e1).
priority(e1,3).
:- not type(e1,quantitative).
:- not field(e1,b).

encoding(e2).
priority(e2,2).
:- not type(e2,nominal).
:- not field(e2,c).

encoding(e3).
priority(e3,1).
:- not type(e3,ordinal).
:- not field(e3,d).
