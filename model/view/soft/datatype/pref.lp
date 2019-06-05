% @constraint 
soft(datatype,string_quantitative,V,E) :- type(V,E,quantitative), field(V,E,F), fieldtype(F,string).

% @constraint 
soft(datatype,string_ordinal,V,E) :- type(V,E,ordinal), field(V,E,F), fieldtype(F,string).

% @constraint 
soft(datatype,string_nominal,V,E) :- type(V,E,nominal), field(V,E,F), fieldtype(F,string).

% @constraint 
soft(datatype,string_temporal,V,E) :- type(V,E,temporal), field(V,E,F), fieldtype(F,string).

% @constraint 
soft(datatype,number_quantitative,V,E) :- type(V,E,quantitative), field(V,E,F), fieldtype(F,number).

% @constraint 
soft(datatype,number_ordinal,V,E) :- type(V,E,ordinal), field(V,E,F), fieldtype(F,number).

% @constraint 
soft(datatype,number_nominal,V,E) :- type(V,E,nominal), field(V,E,F), fieldtype(F,number).

% @constraint 
soft(datatype,number_temporal,V,E) :- type(V,E,temporal), field(V,E,F), fieldtype(F,number).

% @constraint 
soft(datatype,integer_quantitative,V,E) :- type(V,E,quantitative), field(V,E,F), fieldtype(F,integer).

% @constraint 
soft(datatype,integer_ordinal,V,E) :- type(V,E,ordinal), field(V,E,F), fieldtype(F,integer).

% @constraint 
soft(datatype,integer_nominal,V,E) :- type(V,E,nominal), field(V,E,F), fieldtype(F,integer).

% @constraint 
soft(datatype,integer_temporal,V,E) :- type(V,E,temporal), field(V,E,F), fieldtype(F,integer).

% @constraint 
soft(datatype,boolean_quantitative,V,E) :- type(V,E,quantitative), field(V,E,F), fieldtype(F,boolean).

% @constraint 
soft(datatype,boolean_ordinal,V,E) :- type(V,E,ordinal), field(V,E,F), fieldtype(F,boolean).

% @constraint 
soft(datatype,boolean_nominal,V,E) :- type(V,E,nominal), field(V,E,F), fieldtype(F,boolean).

% @constraint 
soft(datatype,boolean_temporal,V,E) :- type(V,E,temporal), field(V,E,F), fieldtype(F,boolean).

% @constraint 
soft(datatype,date_quantitative,V,E) :- type(V,E,quantitative), field(V,E,F), fieldtype(F,date).

% @constraint 
soft(datatype,date_ordinal,V,E) :- type(V,E,ordinal), field(V,E,F), fieldtype(F,date).

% @constraint 
soft(datatype,date_nominal,V,E) :- type(V,E,nominal), field(V,E,F), fieldtype(F,date).

% @constraint 
soft(datatype,date_temporal,V,E) :- type(V,E,temporal), field(V,E,F), fieldtype(F,date).

% @constraint Prefer not to use ordinal for fields with high cardinality.
soft(datatype,high_cardinality_ordinal,V,E) :- type(V,E,ordinal), field(V,E,F), data_fact(cardinality_gt_30,F).

% @constraint Prefer not to use nominal for fields with high cardinality.
soft(datatype,high_cardinality_nominal,V,E) :- type(V,E,nominal), field(V,E,F), data_fact(cardinality_gt_8,F).

% @constraint Prefer not to use high cardinality nominal for color.
soft(datatype,high_cardinality_nominal_color,V,E) :- type(V,E,nominal), channel(V,E,color), field(V,E,F), data_fact(cardinality_gt_20,F).

% @constraint Prefer not to use high cardinality nominal for color.
soft(datatype,high_cardinality_size,V,E) :- type(V,E,nominal), channel(V,E,size), field(V,E,F), data_fact(cardinality_gt_100,F).
