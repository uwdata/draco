% Minimize the feature weight

#minimize { WD,F,V,Q: soft_weight(F,WD), soft(F,V,Q), not base(V) }.

% #minimize { W@2,F,V,Q: soft_weight(F,W), soft(F,V,Q), not base(V) }.
% #minimize { W@1,F,V1,V2,A,B: compare_weight(F,W), compare(F,V1,V2,A,B) }.
