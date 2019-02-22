% Minimize the feature weight

#const max_weight = 1000000.

#minimize { W,F,Q: soft_weight(F,W), soft(F,Q); max_weight,F,Q: soft(F,Q), not soft_weight(F,_) }.
