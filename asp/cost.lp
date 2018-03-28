% !! This is super slow and should only be used for experiments !!

cost(C) :- C = #sum { W,Q,F: violation_weight(F,W), violation(F,Q) }.

#show cost/1.
