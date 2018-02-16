% Corresponding query
%{'mark': '?', 'encodings': [{'channel': '?', 'field': 'Miles_per_Gallon', 'type': 'quantitative', 'aggregate': '?', 'bin': {'maxbins': '?'}}], 'data': {'url': '/Users/clwang/Research/draco/draco/learn/../../data/compassql_examples/input/../data/cars.json'}}

% ====== data definitions ======
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


% ====== query constraints ======
encoding(e0).
1 { channel(e0,p): channel(p) } 1.
field(e0,miles_per_gallon).
type(e0,quantitative).
1 { aggregate(e0,p): aggregate(p) } 1.
1 { bin(e0,p): bin(p) } 1.