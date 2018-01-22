#const type_q_weight = 0.
#const type_o_weight = 1.
#const type_n_weight = 2.
#const aggregate_weight = 1.
#const encoding_weight = 6.
#const same_field_2_weight = 8.
#const same_field_3_weight = 12.
#const same_field_4_weight = 14.
#const same_field_gte5_weight = 18.
#const categorical_cardinality_weight = 5.
#const shape_cardinality_weight = 5.
#const number_nominal_weight = 2.
#const bar_size_weight = 5.
#const tick_size_weight = 5.
#const bin_cardinality_weight = 5.
#const quant_bin_weight = -1.
#const agg_dim_weight = 2.
#const add_count_weight = 20.
#const bar_raw_weight = 2.
#const line_raw_weight = 2.
#const area_raw_weight = 2.
#const multiple_non_pos_weight = 3.
#const non_positional_pref_weight = 10.
#const aggregate_group_by_raw_weight = 3.
#const vertical_dot_weight = 5.
#const x_y_raw_weight = 2.
#const log_weight = 1.
#const zero_weight = -1.
#const position_entropy_weight = 2.
#const m_m_point_weight = 0.
#const m_m_bar_weight = 20.
#const m_m_line_weight = 20.
#const m_m_area_weight = 20.
#const m_m_rule_weight = 25.
#const m_m_text_weight = 2.
#const m_m_tick_weight = 5.
#const m_m_rect_weight = 10.
#const m_d_point_weight = 0.
#const m_d_bar_weight = 20.
#const m_d_line_weight = 20.
#const m_d_area_weight = 20.
#const m_d_rule_weight = 25.
#const m_d_text_weight = 50.
#const m_d_tick_weight = 10.
#const m_d_rect_weight = 20.
#const d_d_point_weight = 0.
#const d_d_bar_weight = 20.
#const d_d_line_weight = 20.
#const d_d_area_weight = 20.
#const d_d_rule_weight = 25.
#const d_d_text_weight = 1.
#const d_d_tick_weight = 10.
#const d_d_rect_weight = 0.

feature_weight("type_q",type_q_weight).
feature_weight("type_o",type_o_weight).
feature_weight("type_n",type_n_weight).
feature_weight("aggregate",aggregate_weight).
feature_weight("encoding",encoding_weight).
feature_weight("same_field_2",same_field_2_weight).
feature_weight("same_field_3",same_field_3_weight).
feature_weight("same_field_4",same_field_4_weight).
feature_weight("same_field_gte5",same_field_gte5_weight).
feature_weight("categorical_cardinality",categorical_cardinality_weight).
feature_weight("shape_cardinality",shape_cardinality_weight).
feature_weight("number_nominal",number_nominal_weight).
feature_weight("bar_size",bar_size_weight).
feature_weight("tick_size",tick_size_weight).
feature_weight("bin_cardinality",bin_cardinality_weight).
feature_weight("quant_bin",quant_bin_weight).
feature_weight("agg_dim",agg_dim_weight).
feature_weight("add_count",add_count_weight).
feature_weight("bar_raw",bar_raw_weight).
feature_weight("line_raw",line_raw_weight).
feature_weight("area_raw",area_raw_weight).
feature_weight("multiple_non_pos",multiple_non_pos_weight).
feature_weight("non_positional_pref",non_positional_pref_weight).
feature_weight("aggregate_group_by_raw",aggregate_group_by_raw_weight).
feature_weight("vertical_dot",vertical_dot_weight).
feature_weight("x_y_raw",x_y_raw_weight).
feature_weight("log",log_weight).
feature_weight("zero",zero_weight).
feature_weight("position_entropy",position_entropy_weight).
feature_weight("m_m_point",m_m_point_weight).
feature_weight("m_m_bar",m_m_bar_weight).
feature_weight("m_m_line",m_m_line_weight).
feature_weight("m_m_area",m_m_area_weight).
feature_weight("m_m_rule",m_m_rule_weight).
feature_weight("m_m_text",m_m_text_weight).
feature_weight("m_m_tick",m_m_tick_weight).
feature_weight("m_m_rect",m_m_rect_weight).
feature_weight("m_d_point",m_d_point_weight).
feature_weight("m_d_bar",m_d_bar_weight).
feature_weight("m_d_line",m_d_line_weight).
feature_weight("m_d_area",m_d_area_weight).
feature_weight("m_d_rule",m_d_rule_weight).
feature_weight("m_d_text",m_d_text_weight).
feature_weight("m_d_tick",m_d_tick_weight).
feature_weight("m_d_rect",m_d_rect_weight).
feature_weight("d_d_point",d_d_point_weight).
feature_weight("d_d_bar",d_d_bar_weight).
feature_weight("d_d_line",d_d_line_weight).
feature_weight("d_d_area",d_d_area_weight).
feature_weight("d_d_rule",d_d_rule_weight).
feature_weight("d_d_text",d_d_text_weight).
feature_weight("d_d_tick",d_d_tick_weight).
feature_weight("d_d_rect",d_d_rect_weight).
