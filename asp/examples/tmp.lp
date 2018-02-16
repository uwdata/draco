%1d-Q.json
% ====== Data definitions ======
data_size(406).

fieldtype(name,string).
cardinality(name,311).
entropy(name,56).

fieldtype(milespergallon,number).
cardinality(milespergallon,129).
entropy(milespergallon,39).

fieldtype(cylinders,number).
cardinality(cylinders,5).
entropy(cylinders,11).

fieldtype(displacement,number).
cardinality(displacement,83).
entropy(displacement,34).

fieldtype(horsepower,number).
cardinality(horsepower,93).
entropy(horsepower,38).

fieldtype(weightinlbs,number).
cardinality(weightinlbs,356).
entropy(weightinlbs,43).

fieldtype(acceleration,number).
cardinality(acceleration,96).
entropy(acceleration,38).

fieldtype(year,date).
cardinality(year,12).

fieldtype(origin,string).
cardinality(origin,3).
entropy(origin,9).


% ====== Query constraints ======
%mark(bar).

encoding(e0).
%1 { channel(e0,P): channel(P) } 1.
field(e0,milespergallon).
type(e0,quantitative).
%1 { aggregate(e0,P): aggregate(P) } 1.
%1 { bin(e0,P): bin(P) } 1.

%{'mark': '?', 'encodings': [{'channel': '?', 'field': 'Miles_per_Gallon', 'type': 'quantitative', 'aggregate': '?', 'bin': {'maxbins': '?'}}], 'data': {'url': '/Users/clwang/Research/draco/draco/learn/../../data/compassql_examples/input/../data/cars.json'}}