% !! This is super slow and should only be used for experiments !!

cost(C) :- C = #sum { W,Q,F: feature_weight(F,W), feature_term(F,Q) }.

#show cost/1.
