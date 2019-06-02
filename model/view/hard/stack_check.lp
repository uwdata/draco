% @constraint Only use stacking for bar and area.
stack_check(stack_without_bar_area,V) :- stack(V,_), not mark(V,bar), not mark(V,area).

% @constraint Don't stack if aggregation is not summative (summative are count, sum, distinct, valid, missing).
stack_check(stack_without_summative_agg,V) :- aggregate(V,E,A), encoding_fact(stacked,V,E), not aggregate_definition(summative,A).

% @constraint Need to stack if we use bar, area with discrete color.
stack_check(no_stack_with_bar_area_discrete_color,V) :- mark(V,(bar;area)), encoding(V,E), channel(V,E,color), encoding_fact(discrete,V,E), not stack(V,_).

% @constraint Can only use stack if we also use discrete color, or detail.
stack_check(stack_without_discrete_color_or_detail,V) :- stack(V,_), not channel_fact(discrete,V,color), { channel(V,E,detail) } = 0.

% @constraint If we use stack and detail, we also have to use quantitative color.
stack_check(stack_detail_without_q_color,V) :- stack(V,_), channel(V,_,detail), not channel(V,_,color).
stack_check(stack_detail_without_q_color,V) :- stack(V,_), channel(V,_,detail), channel(V,E,color), not aggregate(V,E,_).

% @constraint Stack can only be on continuous.
stack_check(stack_discrete,V) :- encoding(V,E), encoding_fact(stacked,V,E), encoding_fact(discrete,V,E).

% @constraint Stack can only be on x or y.
stack_check(stack_without_x_y,V) :- encoding(V,E), encoding_fact(stacked,V,E), not channel(V,E,x), not channel(V,E,y).

% @constraint Cannot use non positional continuous with stack unless it's aggregated.
stack_check(stack_with_non_positional_non_agg,V) :- stack(V,_), encoding(V,E), channel_definition(non_positional,C), channel(V,E,C), not aggregate(V,E,_), encoding_fact(continuous,V,E).

% @constraint Vega-Lite currently supports 8 shapes.
stack_check(shape_with_cardinality_gt_eight,V) :- channel(V,E,shape), field(V,E,F), data_fact(cardinality_gt_8,F).

% @constraint At most 20 categorical colors.
stack_check(color_with_cardinality_gt_twenty,V) :- channel(V,E,color), encoding_fact(discrete,V,E), field(V,E,F), data_fact(cardinality_gt_20,F), F > 20.
