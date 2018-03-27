% ====== Data definitions ======
fieldtype(name,string).

% ====== Visualization specification ======

mark(point).

encoding(e0).
field(e0,name).
channel(e0,x).
type(e0,quantitative).  % canot use string as quantitative
