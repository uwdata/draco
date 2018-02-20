% ====== Data definitions ======
data_size(406).

fieldtype(name,string).
cardinality(name,311).
entropy(name,56).

fieldtype(miles_per_gallon,number).
cardinality(miles_per_gallon,129).
entropy(miles_per_gallon,39).

fieldtype(cylinders,number).
cardinality(cylinders,5).
entropy(cylinders,11).

fieldtype(displacement,number).
cardinality(displacement,83).
entropy(displacement,34).

fieldtype(horsepower,number).
cardinality(horsepower,93).
entropy(horsepower,38).

fieldtype(weight_in_lbs,number).
cardinality(weight_in_lbs,356).
entropy(weight_in_lbs,43).

fieldtype(acceleration,number).
cardinality(acceleration,96).
entropy(acceleration,38).

fieldtype(year,date).
cardinality(year,12).

fieldtype(origin,string).
cardinality(origin,3).
entropy(origin,9).


% ====== Query constraints ======
encoding(e0).
field(e0,miles_per_gallon).
type(e0,quantitative).