% ====== Preferences ======

% prefer quantitative > ordinal > nominal
#const type_weight_q = 0.
#const type_weight_o = 1.
#const type_weight_n = 2.

:~ type(_,q). [type_weight_q]
:~ type(_,o). [type_weight_o]
:~ type(_,n). [type_weight_n]

% prefer to use raw (no aggregate)
#const agg_weight = 1.
:~ aggregate(E,_). [agg_weight,E]

% prefer to use fewer encodings
#const encoding_weight = 6.
:~ encoding(E). [encoding_weight,E]

% prefer not to use the same field multiple times
#const same_field_weight = 10.
:~ { field(E,_) } = K, P = (K - 1) * same_field_weight, encoding(E), K > 1. [P,E]

% categorical color channel should not have too high cardinality
#const categorical_cardinality_weight = 5.
:~ channel(E,color), type(E,nominal), cardinality(E,C), C > 20. [categorical_cardinality_weight,E]

% shape channel should not have too high cardinality
#const shape_cardinality_weight = 5.
:~ channel(E,shape), cardinality(E,C), C > 6. [shape_cardinality_weight,E]

% numbers should not be nominal
#const number_nominal_weight = 2.
:~ type(E,nominal), field(E,F), fieldtype(F,number). [number_nominal_weight,E]

% bar and tick should not use size
#const bar_size_weight = 5.
:~ mark(bar), channel(_,size). [bar_size_weight]
#const tick_size_weight = 5.
:~ mark(tick), channel(_,size). [tick_size_weight]

% binned quantitative field should not have too low cardinality
#const bin_cardinality_weight = 5.
:~ type(E,quantitative), bin(E,_), cardinality(E,C), C < 15. [bin_cardinality_weight,E]

% prefer quantitative for bin
#const quant_bin_weight = 1.
:~ bin(E,_), type(E,quantitative). [quant_bin_weight,E]

% aggregate should also have a dimension
#const agg_dim_weight = 2.
:~ aggregate(_,_), not dimension(_). [agg_dim_weight]

% plots with only ordinal, binned q, or t with time unit should add count
#const add_count_weight = 20.
:~ not not dimension(_), not aggregate(_,count). [add_count_weight]

% don't use bar, line, or area for raw data as it leads to occulusion
#const bar_raw_weight = 2.
:~ mark(bar), not aggregate(_,_). [bar_raw_weight]
#const line_raw_weight = 2.
:~ mark(line), not aggregate(_,_). [line_raw_weight]
#const area_raw_weight = 2.
:~ mark(area), not aggregate(_,_). [area_raw_weight]

% prefer not to use multiple non-positional encoding channels
#const multiple_non_pos_weight = 3.
:~ {channel(_,C): non_positional(C)} > 1. [multiple_non_pos_weight]

% prefer not to use non-positional channels until all positional channels are used
#const non_positional_pref_weight = 10.
:~ channel(_,C), non_positional(C), not channel(_,(x;y)). [non_positional_pref_weight]

% aggregate plots should not use raw continuous as group by
#const aggregate_group_by_raw_weight = 3.
:~ aggregate(_,_), type(E,quantitative), not bin(E,_), not aggregate(E,_). [aggregate_group_by_raw_weight,E]

% prefer not to use vertical for dot plot
#const vertical_dot_weight = 5.
:~ channel(_,y), not channel(_,C), C != y, channel(C), not mark(bar). [vertical_dot_weight]

% prefer not to use plot with both x and y dimension and no aggregate
#const x_y_raw_weight = 2.
:~ channel(EX,x), dimension(EX), channel(EY,y), dimension(EY), not aggregate(_,_). [x_y_raw_weight]

% prefer not to use log scale
#const log_weight = 1.
:~ log(E), encoding(E). [log_weight,E]

% prefer to include zero
#const zero_weight = -1.
:~ zero(E), encoding(E). [zero_weight,E]


% ====== Rankings ======

% measure by measure
is_m_m :- channel_meas(x), channel_meas(y).

#const m_m_point_weight = 0.
#const m_m_bar_weight = 20.
#const m_m_line_weight = 20.
#const m_m_area_weight = 20.
#const m_m_rule_weight = 25.
#const m_m_text_weight = 2.
#const m_m_tick_weight = 5.
#const m_m_rect_weight = 10.

:~ is_m_m, mark(point). [m_m_point_weight]
:~ is_m_m, mark(bar). [m_m_bar_weight]
:~ is_m_m, mark(line). [m_m_line_weight]
:~ is_m_m, mark(area). [m_m_area_weight]
:~ is_m_m, mark(rule). [m_m_rule_weight]
:~ is_m_m, mark(text). [m_m_text_weight]
:~ is_m_m, mark(tick). [m_m_tick_weight]
:~ is_m_m, mark(rect). [m_m_rect_weight]

% measure by dimension
is_m_d :- channel_meas(x), channel_dim(y).
is_m_d :- channel_meas(y), channel_dim(x).

#const m_d_point_weight = 0.
#const m_d_bar_weight = 20.
#const m_d_line_weight = 20.
#const m_d_area_weight = 20.
#const m_d_rule_weight = 25.
#const m_d_text_weight = 50.
#const m_d_tick_weight = 10.
#const m_d_rect_weight = 20.

:~ is_m_d, mark(point). [m_d_point_weight]
:~ is_m_d, mark(bar). [m_d_bar_weight]
:~ is_m_d, mark(line). [m_d_line_weight]
:~ is_m_d, mark(area). [m_d_area_weight]
:~ is_m_d, mark(rule). [m_d_rule_weight]
:~ is_m_d, mark(text). [m_d_text_weight]
:~ is_m_d, mark(tick). [m_d_tick_weight]
:~ is_m_d, mark(rect). [m_d_rect_weight]

% dimension by dimension
is_d_d :- channel_dim(x), channel_dim(y).

#const d_d_point_weight = 0.
#const d_d_bar_weight = 20.
#const d_d_line_weight = 20.
#const d_d_area_weight = 20.
#const d_d_rule_weight = 25.
#const d_d_text_weight = 1.
#const d_d_tick_weight = 10.
#const d_d_rect_weight = 0.

:~ is_d_d, mark(point). [d_d_point_weight]
:~ is_d_d, mark(bar). [d_d_bar_weight]
:~ is_d_d, mark(line). [d_d_line_weight]
:~ is_d_d, mark(area). [d_d_area_weight]
:~ is_d_d, mark(rule). [d_d_rule_weight]
:~ is_d_d, mark(text). [d_d_text_weight]
:~ is_d_d, mark(tick). [d_d_tick_weight]
:~ is_d_d, mark(rect). [d_d_rect_weight]
