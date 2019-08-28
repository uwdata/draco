% === Task - channel correlations ===

% @constraint Continuous x for value tasks.
soft(task,value_continuous_x,V,true) :- task(value), channel(V,E,x), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous y for value tasks.
soft(task,value_continuous_y,V,true) :- task(value), channel(V,E,y), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous color for value tasks.
soft(task,value_continuous_color,V,true) :- task(value), channel(V,E,color), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous size for value tasks.
soft(task,value_continuous_size,V,true) :- task(value), channel(V,E,size), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous text for value tasks.
soft(task,value_continuous_text,V,true) :- task(value), channel(V,E,text), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete x for value tasks.
soft(task,value_discrete_x,V,true) :- task(value), channel(V,E,x), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete y for value tasks.
soft(task,value_discrete_y,V,true) :- task(value), channel(V,E,y), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete color for value tasks.
soft(task,value_discrete_color,V,true) :- task(value), channel(V,E,color), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete shape for value tasks.
soft(task,value_discrete_shape,V,true) :- task(value), channel(V,E,shape), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete size for value tasks.
soft(task,value_discrete_size,V,true) :- task(value), channel(V,E,size), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete text for value tasks.
soft(task,value_discrete_text,V,true) :- task(value), channel(V,E,text), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete row for value tasks.
soft(task,value_discrete_row,V,true) :- task(value), channel(V,E,row), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete column for value tasks.
soft(task,value_discrete_column,V,true) :- task(value), channel(V,E,column), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous x for summary tasks.
soft(task,summary_continuous_x,V,true) :- task(summary), channel(V,E,x), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous y for summary tasks.
soft(task,summary_continuous_y,V,true) :- task(summary), channel(V,E,y), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous color for summary tasks.
soft(task,summary_continuous_color,V,true) :- task(summary), channel(V,E,color), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous size for summary tasks.
soft(task,summary_continuous_size,V,true) :- task(summary), channel(V,E,size), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Continuous text for summary tasks.
soft(task,summary_continuous_text,V,true) :- task(summary), channel(V,E,text), encoding_fact(continuous,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete x for summary tasks.
soft(task,summary_discrete_x,V,true) :- task(summary), channel(V,E,x), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete y for summary tasks.
soft(task,summary_discrete_y,V,true) :- task(summary), channel(V,E,y), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete color for summary tasks.
soft(task,summary_discrete_color,V,true) :- task(summary), channel(V,E,color), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete shape for summary tasks.
soft(task,summary_discrete_shape,V,true) :- task(summary), channel(V,E,shape), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete size for summary tasks.
soft(task,summary_discrete_size,V,true) :- task(summary), channel(V,E,size), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete text for summary tasks.
soft(task,summary_discrete_text,V,true) :- task(summary), channel(V,E,text), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete row for summary tasks.
soft(task,summary_discrete_row,V,true) :- task(summary), channel(V,E,row), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Discrete column for summary tasks.
soft(task,summary_discrete_column,V,true) :- task(summary), channel(V,E,column), encoding_fact(discrete,V,E), encoding_fact(interesting,V,E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_high, E) :- channel(V,E,color), field(V,E,F), entropy(F,high), type(V,E,quantitative), encoding_fact(interesting,V,E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_low, E) :- channel(V,E,color), field(V,E,F), entropy(F,low), type(V,E,quantitative), encoding_fact(interesting,V,E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(size_entropy_high, E) :- channel(V,E,size), field(V,E,F), entropy(F,high), type(V,E,quantitative), encoding_fact(interesting,V,E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(size_entropy_low, E) :- channel(V,E,size), field(V,E,F), entropy(F,low), type(V,E,quantitative), encoding_fact(interesting,V,E).

% @constraint Overplotting. Prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overplot.
soft(position_entropy,E) :- channel(V,E,(x;y)), encoding_fact(continuous,V,E), field(V,E,F), cardinality(F,C), C > 100, entropy(F,low), not aggregate(E,_).
