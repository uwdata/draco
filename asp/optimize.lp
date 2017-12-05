% Minimize the feature weight

feature_term(F,0) :- feature_term(F).
#minimize { W,Q: feature_weight(F,W), feature_term(F,Q) }.
