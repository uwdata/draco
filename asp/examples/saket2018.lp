% test with `clingo asp/_saket2018.lp asp/examples/saket2018.lp --opt-mode=optN --quiet=1 --project`

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
:- not channel(e0,y).
:- not field(e0,q2).
:- not type(e0,quantitative).

encoding(e1).
:- not channel(e1,x).
:- not field(e1,o1).
:- not type(e1,ordinal).


% ====== Task constraint ======
task(value).
