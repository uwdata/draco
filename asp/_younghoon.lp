% restrict to subset that is supported by Kim et al

#include "asp/define.lp".
#include "asp/generate.lp".
#include "asp/test.lp".
#include "asp/features.lp".
#include "asp/weights.lp".
#include "asp/assign_weights.lp".
#include "asp/optimize.lp".
#include "asp/count.lp".
#include "asp/output.lp".

% only three encodings
3 { encoding(E): encoding(E) } 3.

% two quantitative, one nominal
2 { type(E,quantitative): encoding(E) } 2.
1 { type(E,nominal): encoding(E) } 1.
:- type(_,ordinal).

% only scatterplots
:- not mark(point).

% always use zero for quantitative
:- type(E,quantitative), not zero(E).
