from draco.run import run

# program = """% ====== Data definitions ======
# data("cars.json").
# num_rows(142).

# fieldtype(horsepower,number).
# cardinality(horsepower,94).

# fieldtype(acceleration,number).
# cardinality(acceleration,96).

# % ====== Query constraints ======
# view(v1).

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
# view(v1).
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



program = """view("view").
num_rows(406).

fieldtype("Acceleration",number).
cardinality("Acceleration", 96).
fieldtype("Cylinders",number).
cardinality("Cylinders", 5).
fieldtype("Displacement",number).
cardinality("Displacement", 83).
fieldtype("Horsepower",number).
cardinality("Horsepower", 94).
fieldtype("Miles_per_Gallon",number).
cardinality("Miles_per_Gallon", 130).
fieldtype("Name",string).
cardinality("Name", 311).
fieldtype("Origin",string).
cardinality("Origin", 3).
fieldtype("Weight_in_lbs",number).
cardinality("Weight_in_lbs", 356).
fieldtype("Year",number).
cardinality("Year", 12).

mark("view",point).
encoding("view",e0).
:- not field("view",e0,"Horsepower").
aggregate("view",e0,mean).
channel("view",e0,x).
encoding("view",e1).
:- not field("view",e1,"Miles_per_Gallon").
view("first").
num_rows(406).

fieldtype("Acceleration",number).
cardinality("Acceleration", 96).
fieldtype("Cylinders",number).
cardinality("Cylinders", 5).
fieldtype("Displacement",number).
cardinality("Displacement", 83).
fieldtype("Horsepower",number).
cardinality("Horsepower", 94).
fieldtype("Miles_per_Gallon",number).
cardinality("Miles_per_Gallon", 130).
fieldtype("Name",string).
cardinality("Name", 311).
fieldtype("Origin",string).
cardinality("Origin", 3).
fieldtype("Weight_in_lbs",number).
cardinality("Weight_in_lbs", 356).
fieldtype("Year",number).
cardinality("Year", 12).

encoding("first",e0).
base("first").
:- not field("first",e0,"Horsepower").
aggregate("first",e0,mean).
channel("first",e0,x).
encoding("first",e1).
:- not field("first",e1,"Miles_per_Gallon").
view("first").
encoding("first",e0).
encoding("first",e1).
aggregate("first",e0,mean).
channel("first",e0,x).
bin("first",e1,10).
type("first",e0,quantitative).
type("first",e1,quantitative).
field("first",e0,"Horsepower").
field("first",e1,"Miles_per_Gallon").
channel("first",e1,y).
zero("first",e0).
mark("first",bar).
:- not { encoding("first",_) } = 2.
:- not { channel("first",_,_) } = 2.
:- not { bin("first",_,_) } = 1.
:- not { type("first",_,_) } = 2.
:- not { field("first",_,_) } = 2.
:- not { zero("first",_) } = 1."""

asp = program.split('\n')
result = run(asp)

print('{0}'.format('\n'.join(result.props)))