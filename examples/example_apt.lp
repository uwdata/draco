% test with `clingo asp/_apt.lp examples/example_apt.lp --opt-mode=optN --quiet=1 --project -c max_extra_encs=0`

% ====== Data definitions ======
data_size(20).

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
type(e0,quantitative).
field(e0,a).
priority(e0,4).

encoding(e1).
type(e1,quantitative).
field(e1,b).
priority(e1,3).

encoding(e2).
type(e2,nominal).
field(e2,c).
priority(e2,2).

encoding(e3).
type(e3,ordinal).
field(e3,d).
priority(e3,1).
