
% allowed marktypes
:- not mark(bar), not mark(line), not mark(point).

% two encodings
2 = { encoding(E): encoding(E) }.

% only use x and y
:- not channel(_,(x;y)).

% y has to be aggregated and quantitative
:- channel(E,y), not type(E,quantitative).
:- channel(E,y), not aggregate(E,mean).
