% test with `clingo asp/_bahador.lp examples/example_bahador.lp --opt-mode=optN --quiet=1 --project`

% ====== Data definitions ======
num_rows(407).

fieldtype(n,string).
cardinality(n,9).

fieldtype(o1,number).
cardinality(o1,25).

fieldtype(q2,number).
cardinality(q2,407).


% ====== Query constraints ======
encoding(e0).
channel(e0,y).
field(e0,q2).
type(e0,quantitative).

encoding(e1).
channel(e1,x).
field(e1,o1).
type(e1,quantitative).


% ====== Task constraint ======
task(value).
