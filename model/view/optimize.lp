#const infinity = 999999999.

#minimize { W,TYPE,NAME,V,X: soft(TYPE,NAME,V,X), soft_weight(TYPE,NAME,W); infinity,TYPE,NAME,V,X: hard(TYPE,NAME,V,X) }.
