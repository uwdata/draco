% @constraint Continuous by continuous for point mark.
soft(mark_type,c_c_point,V,true) :- chart_fact(continuous_continuous,V), mark(V,point).

% @constraint Continuous by continuous for circle mark.
soft(mark_type,c_c_circle,V,true) :- chart_fact(continuous_continuous,V), mark(V,circle).

% @constraint Continuous by continuous for square mark.
soft(mark_type,c_c_square,V,true) :- chart_fact(continuous_continuous,V), mark(V,square).

% @constraint Continuous by continuous for line mark.
soft(mark_type,c_c_line,V,true) :- chart_fact(continuous_continuous,V), mark(V,line).

% @constraint Continuous by continuous for area mark.
soft(mark_type,c_c_area,V,true) :- chart_fact(continuous_continuous,V), mark(V,area).

% @constraint Continuous by continuous for text mark.
soft(mark_type,c_c_text,V,true) :- chart_fact(continuous_continuous,V), mark(V,text).

% @constraint Continuous by continuous for tick mark.
soft(mark_type,c_c_tick,V,true) :- chart_fact(continuous_continuous,V), mark(V,tick).

% @constraint Continuous by discrete for point mark.
soft(mark_type,c_d_point,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,point).

% @constraint Continuous by discrete for bar mark.
soft(mark_type,c_d_bar,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,bar).

% @constraint Continuous by discrete for line mark.
soft(mark_type,c_d_line,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,line).

% @constraint Continuous by discrete for area mark.
soft(mark_type,c_d_area,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,area).

% @constraint Continuous by discrete for text mark.
soft(mark_type,c_d_text,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,text).

% @constraint Continuous by discrete for tick mark.
soft(mark_type,c_d_tick,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,tick).

% @constraint Continuous by discrete for point mark with no overlap.
soft(mark_type,c_d_no_overlap_point,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,point).

% @constraint Continuous by discrete for bar mark with no overlap.
soft(mark_type,c_d_no_overlap_bar,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,bar).

% @constraint Continuous by discrete for line mark with no overlap.
soft(mark_type,c_d_no_overlap_line,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,line).

% @constraint Continuous by discrete for area mark with no overlap.
soft(mark_type,c_d_no_overlap_area,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,area).

% @constraint Continuous by discrete for text mark with no overlap.
soft(mark_type,c_d_no_overlap_text,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,text).

% @constraint Continuous by discrete for tick mark with no overlap.
soft(mark_type,c_d_no_overlap_tick,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,tick).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_point,V,true) :- chart_fact(discrete_discrete,V), mark(V,point).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_text,V,true) :- chart_fact(discrete_discrete,V), mark(V,text).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_rect,V,true) :- chart_fact(discrete_discrete,V), mark(V,rect).

% @constraint Prefer to use line chart for c_d temporal.
soft(mark_type,c_d_temporal_not_line,V,true) :- chart_fact(continuous_discrete,V), not mark(V,line), encoding_fact(discrete,V,E), type(V,E,temporal).
