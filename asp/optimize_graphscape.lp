% #minimize { W@1,F,V,Q: soft_weight(F,W), soft(F,V,Q) }.
% #minimize { W@2,F,V1,V2,A,B: compare_weight(F,W), compare(F,V1,V2,A,B) }.

#minimize { W,F,V1,V2,A,B: compare_weight(F,W), compare(F,V1,V2,A,B) }.
