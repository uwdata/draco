%% READ VALUE

% @constraint Continuous by continuous for point mark.
soft(mark_type,c_c_point_read_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,point).

% @constraint Continuous by continuous for line mark.
soft(mark_type,c_c_line_read_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,line).

% @constraint Continuous by continuous for area mark.
soft(mark_type,c_c_area_read_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,area).

% @constraint Continuous by continuous for text mark.
soft(mark_type,c_c_text_read_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,text).

% @constraint Continuous by continuous for tick mark.
soft(mark_type,c_c_tick_read_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,tick).

% @constraint Continuous by discrete for point mark.
soft(mark_type,c_d_point_read_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,point).

% @constraint Continuous by discrete for bar mark.
soft(mark_type,c_d_bar_read_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,bar).

% @constraint Continuous by discrete for line mark.
soft(mark_type,c_d_line_read_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,line).

% @constraint Continuous by discrete for area mark.
soft(mark_type,c_d_area_read_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,area).

% @constraint Continuous by discrete for text mark.
soft(mark_type,c_d_text_read_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,text).

% @constraint Continuous by discrete for tick mark.
soft(mark_type,c_d_tick_read_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,tick).

% @constraint Continuous by discrete for point mark with no overlap.
soft(mark_type,c_d_no_overlap_point_read_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,point).

% @constraint Continuous by discrete for bar mark with no overlap.
soft(mark_type,c_d_no_overlap_bar_read_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,bar).

% @constraint Continuous by discrete for line mark with no overlap.
soft(mark_type,c_d_no_overlap_line_read_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,line).

% @constraint Continuous by discrete for area mark with no overlap.
soft(mark_type,c_d_no_overlap_area_read_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,area).

% @constraint Continuous by discrete for text mark with no overlap.
soft(mark_type,c_d_no_overlap_text_read_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,text).

% @constraint Continuous by discrete for tick mark with no overlap.
soft(mark_type,c_d_no_overlap_tick_read_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,tick).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_point_read_value,V,true) :- chart_fact(discrete_discrete,V), mark(V,point).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_text_read_value,V,true) :- chart_fact(discrete_discrete,V), mark(V,text).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_rect_read_value,V,true) :- chart_fact(discrete_discrete,V), mark(V,rect).


%% COMPARE VALUE

% @constraint Continuous by continuous for point mark.
soft(mark_type,c_c_point_compare_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,point).

% @constraint Continuous by continuous for line mark.
soft(mark_type,c_c_line_compare_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,line).

% @constraint Continuous by continuous for area mark.
soft(mark_type,c_c_area_compare_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,area).

% @constraint Continuous by continuous for text mark.
soft(mark_type,c_c_text_compare_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,text).

% @constraint Continuous by continuous for tick mark.
soft(mark_type,c_c_tick_compare_value,V,true) :- chart_fact(continuous_continuous,V), mark(V,tick).

% @constraint Continuous by discrete for point mark.
soft(mark_type,c_d_point_compare_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,point).

% @constraint Continuous by discrete for bar mark.
soft(mark_type,c_d_bar_compare_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,bar).

% @constraint Continuous by discrete for line mark.
soft(mark_type,c_d_line_compare_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,line).

% @constraint Continuous by discrete for area mark.
soft(mark_type,c_d_area_compare_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,area).

% @constraint Continuous by discrete for text mark.
soft(mark_type,c_d_text_compare_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,text).

% @constraint Continuous by discrete for tick mark.
soft(mark_type,c_d_tick_compare_value,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,tick).

% @constraint Continuous by discrete for point mark with no overlap.
soft(mark_type,c_d_no_overlap_point_compare_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,point).

% @constraint Continuous by discrete for bar mark with no overlap.
soft(mark_type,c_d_no_overlap_bar_compare_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,bar).

% @constraint Continuous by discrete for line mark with no overlap.
soft(mark_type,c_d_no_overlap_line_compare_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,line).

% @constraint Continuous by discrete for area mark with no overlap.
soft(mark_type,c_d_no_overlap_area_compare_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,area).

% @constraint Continuous by discrete for text mark with no overlap.
soft(mark_type,c_d_no_overlap_text_compare_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,text).

% @constraint Continuous by discrete for tick mark with no overlap.
soft(mark_type,c_d_no_overlap_tick_compare_value,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,tick).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_point_compare_value,V,true) :- chart_fact(discrete_discrete,V), mark(V,point).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_text_compare_value,V,true) :- chart_fact(discrete_discrete,V), mark(V,text).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_rect_compare_value,V,true) :- chart_fact(discrete_discrete,V), mark(V,rect).


%% FIND MAX

% @constraint Continuous by continuous for point mark.
soft(mark_type,c_c_point_find_maximum,V,true) :- chart_fact(continuous_continuous,V), mark(V,point).

% @constraint Continuous by continuous for line mark.
soft(mark_type,c_c_line_find_maximum,V,true) :- chart_fact(continuous_continuous,V), mark(V,line).

% @constraint Continuous by continuous for area mark.
soft(mark_type,c_c_area_find_maximum,V,true) :- chart_fact(continuous_continuous,V), mark(V,area).

% @constraint Continuous by continuous for text mark.
soft(mark_type,c_c_text_find_maximum,V,true) :- chart_fact(continuous_continuous,V), mark(V,text).

% @constraint Continuous by continuous for tick mark.
soft(mark_type,c_c_tick_find_maximum,V,true) :- chart_fact(continuous_continuous,V), mark(V,tick).

% @constraint Continuous by discrete for point mark.
soft(mark_type,c_d_point_find_maximum,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,point).

% @constraint Continuous by discrete for bar mark.
soft(mark_type,c_d_bar_find_maximum,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,bar).

% @constraint Continuous by discrete for line mark.
soft(mark_type,c_d_line_find_maximum,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,line).

% @constraint Continuous by discrete for area mark.
soft(mark_type,c_d_area_find_maximum,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,area).

% @constraint Continuous by discrete for text mark.
soft(mark_type,c_d_text_find_maximum,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,text).

% @constraint Continuous by discrete for tick mark.
soft(mark_type,c_d_tick_find_maximum,V,true) :- chart_fact(continuous_discrete,V), not chart_fact(no_overlap,V), mark(V,tick).

% @constraint Continuous by discrete for point mark with no overlap.
soft(mark_type,c_d_no_overlap_point_find_maximum,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,point).

% @constraint Continuous by discrete for bar mark with no overlap.
soft(mark_type,c_d_no_overlap_bar_find_maximum,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,bar).

% @constraint Continuous by discrete for line mark with no overlap.
soft(mark_type,c_d_no_overlap_line_find_maximum,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,line).

% @constraint Continuous by discrete for area mark with no overlap.
soft(mark_type,c_d_no_overlap_area_find_maximum,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,area).

% @constraint Continuous by discrete for text mark with no overlap.
soft(mark_type,c_d_no_overlap_text_find_maximum,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,text).

% @constraint Continuous by discrete for tick mark with no overlap.
soft(mark_type,c_d_no_overlap_tick_find_maximum,V,true) :- chart_fact(continuous_discrete,V), chart_fact(no_overlap,V), mark(V,tick).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_point_find_maximum,V,true) :- chart_fact(discrete_discrete,V), mark(V,point).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_text_find_maximum,V,true) :- chart_fact(discrete_discrete,V), mark(V,text).

% @constraint Discrete by discrete for point mark.
soft(mark_type,d_d_rect_find_maximum,V,true) :- chart_fact(discrete_discrete,V), mark(V,rect).
