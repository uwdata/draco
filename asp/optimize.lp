% Minimize the feature weight

#minimize { WD * 10,F,V,Q: soft_weight(F,WD), soft(F,V,Q); WG,F,V1,V2,A,B: compare_weight(F,WG), compare(F,V1,V2,A,B) }.

% #minimize { W@2,F,V,Q: soft_weight(F,W), soft(F,V,Q) }.
% #minimize { W@1,F,V1,V2: compare_weight(F,W), compare(F,V1,V2) }.
