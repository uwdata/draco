% @constraint Bars and area cannot overlap.
view_check(bar_area_overlap,V) :- mark(V,(bar;area)), not chart_fact(no_overlap,V).

% @constraint Rects shouldn't overlap. They are used for discrete heatmaps.
view_check(rect_overlap,V) :- mark(V,rect), not chart_fact(no_overlap,V).

% @constraint Text mark requires text channel.
view_check(text_mark_without_text_channel,V) :- mark(V,text), not channel(V,_,text).

% @constraint Text channel requires text mark.
view_check(text_channel_without_text_mark,V) :- channel(V,E,text), not mark(V,text).

% @constraint Point, tick, and bar require x or y channel.
view_check(point_tick_bar_without_x_or_y,V) :- mark(V,(point;tick;bar)), not channel(V,_,x), not channel(V,_,y).

% @constraint Line and area require x and y channel.
view_check(line_area_without_x_y,V) :- mark(V,(line;area)), not channel(V,_,(x;y)).

% @constraint Line and area cannot have two discrete.
view_check(line_area_with_discrete,V) :- mark(V,(line;area)), channel_fact(discrete,V,x), channel_fact(discrete,V,y).

% @constraint Bar and tick cannot have both x and y continuous.
view_check(bar_tick_rule_continuous_x_y,V) :- mark(V,(bar;tick;rule)), channel_fact(continuous,V,x), channel_fact(continuous,V,y).

% @constraint Bar, tick, line, area require some continuous variable on x or y.
view_check(bar_tick_area_line_without_continuous_x_y,V) :- mark(V,(bar;tick;area;line)), not channel_fact(continuous,V,x), not channel_fact(continuous,V,y).

% @constraint Shape channel requires point mark.
view_check(shape_without_point,V) :- channel(V,_,shape), not mark(V,point).

% @constraint Size only works with some marks. Vega-Lite can also size lines, and ticks but that would violate best practices.
view_check(size_without_point_text,V) :-  channel(V,_,size), not mark(V,point), not mark(V,text).

% @constraint Detail requires aggregation. Detail adds a field to the group by. Detail could also be used to add information to tooltips. We may remove this later.
view_check(detail_without_agg,V) :- channel(V,_,detail), not aggregate(V,_,_).

% @constraint Rect mark needs discrete x and y.
view_check(rect_without_d_d,V) :- mark(V,rect), not chart_fact(discrete_discrete,V).

% @constraint Don't use the same field on x and y.
view_check(same_field_x_and_y,V) :- view(V), { field(V,E,F) : channel(V,E,x); field(V,E,F) : channel(V,E,y) } >= 2, fieldtype(F,_).

% @constraint Don't use count on x and y.
view_check(count_on_x_and_y,V):- channel(V,EX,x), channel(V,EY,y), aggregate(V,EX,count), aggregate(V,EY,count).

% @constraint If we use aggregation, then all continuous fields need to be aggeragted.
view_check(aggregate_not_all_continuous,V):- aggregate(V,E,_), encoding_fact(continuous,V,E), not aggregate(V,E,_).

% @constraint Don't use row without y. Just using y is simpler.
view_check(row_no_y,V) :- channel(V,_,row), not channel(V,_,y).

% @constraint Don't use column without x. Just using x is simpler.
view_check(column_no_x,V) :- channel(V,_,column), not channel(V,_,x).

% @constraint Don't use size for temporal
view_check(temporal_size,V) :- channel(V,E,size), type(V,E,temporal).
