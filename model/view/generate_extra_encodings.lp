% encodings

% maximum number for each multi channel encoding
#const max_extra_encs = 4.

obj_id(1..max_extra_encs).

0 { encoding(V,E): view(V), obj_id(E) } max_extra_encs.

:- view(V), not encoding(V,ID), encoding(V,ID-1), obj_id(ID), obj_id(ID-1).
