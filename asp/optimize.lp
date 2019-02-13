% Minimize the feature weight

% #minimize { W,F,V,Q: soft_weight(F,W), soft(F,V,Q); W,F,V1,V2: compare_weight(F,W), compare(F,V1,V2) }.

#minimize { W@2,F,V,Q: soft_weight(F,W), soft(F,V,Q) }.
#minimize { W@1,F,V1,V2: compare_weight(F,W), compare(F,V1,V2) }.