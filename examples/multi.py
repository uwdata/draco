from draco.run import run

# program = """% ====== Data definitions ======
# data("cars.json").
# num_rows(142).

# fieldtype(horsepower,number).
# cardinality(horsepower,94).

# fieldtype(acceleration,number).
# cardinality(acceleration,96).

# % ====== Query constraints ======
# visualization(v1).

# encoding(v1,e0).
# :- not field(v1,e0,acceleration).

# encoding(v1,e1).
# :- not field(v1,e1,horsepower)."""

# asp = program.split('\n')

# result = run(asp)

# print('{0}'.format('\n'.join(result.props)))



# program = """% ====== Data definitions ======
# data("cars.json").
# num_rows(142).

# fieldtype(horsepower,number).
# cardinality(horsepower,94).

# fieldtype(acceleration,number).
# cardinality(acceleration,96).

# % ====== Query constraints ======
# visualization(v1).
# data("cars.json").
# type(v1,e0,quantitative).
# type(v1,e1,quantitative).
# field(v1,e0,acceleration).
# field(v1,e1,horsepower).
# channel(v1,e0,x).
# channel(v1,e1,y).
# zero(v1,e0).
# zero(v1,e1).
# mark(v1,point)."""

# asp = program.split('\n')
# result = run(asp)

# print('{0}'.format('\n'.join(result.props)))



program = """% ====== Data definitions ======
data("cars.json").
num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

fieldtype(acceleration,number).
cardinality(acceleration,96).

% ====== Query constraints ======
visualization(v1).
% base(v1).
data("cars.json").
encoding(v1,e0).
encoding(v1,e1).
type(v1,e0,quantitative).
type(v1,e1,quantitative).
field(v1,e0,acceleration).
field(v1,e1,horsepower).
channel(v1,e0,x).
channel(v1,e1,y).
zero(v1,e0).
zero(v1,e1).
:- log(v1,_).
:- bin(v1,_,_).
:- aggregate(v1,_,_).
:- stack(v1,_).
:- not { encoding(v1,_) } = 2.
mark(v1,point).

visualization(v2).

mark(v2,bar).

encoding(v2,e0).
:- not field(v2,e0,acceleration).

encoding(v2,e1).
:- not field(v2,e1,horsepower)."""

asp = program.split('\n')
result = run(asp)

print('{0}'.format('\n'.join(result.props)))