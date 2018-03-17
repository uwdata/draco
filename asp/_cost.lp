% Instead of running optimization, just count the cost of violations
% !! This is super slow and should only be used for experiments !!

#include "asp/define.lp".
#include "asp/generate.lp".
#include "asp/test.lp".
#include "asp/features.lp".
#include "asp/weights.lp".
#include "asp/assign_weights.lp".
#include "asp/count.lp".
#include "asp/output.lp".

cost(C) :- C = #sum { W,Q,F: feature_weight(F,W), feature_term(F,Q) }.

#show cost/1.
