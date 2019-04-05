% Minimize the feature weight

#minimize { W,F,Q: soft_weight(F,W), soft(F,Q); #inf,F,Q: soft(F,Q), not soft_weight(F,_); #inf,F: hard(F); #inf,F,Q: hard(F,Q); #inf,F,Q1,Q2: hard(F,Q1,Q2) }.
