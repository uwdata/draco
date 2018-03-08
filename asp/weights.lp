% Weights as constants

#const type_q_weight = 0.
#const type_o_weight = 2.
#const type_n_weight = 4.
#const aggregate_weight = 5.
#const bin_weight = 1.
#const bin_high_weight = 6.
#const bin_low_weight = 6.
#const encoding_weight = 0.
#const encoding_field_weight = 6.
#const same_field_2_weight = 8.
#const same_field_gte3_weight = 16.
#const count_twice_weight = 50.
#const categorical_cardinality_weight = 5.
#const shape_cardinality_weight = 5.
#const number_nominal_weight = 10.
#const bin_cardinality_weight = 5.
#const quant_bin_weight = 1.
#const agg_dim_weight = 2.
#const only_discrete_weight = 30.
#const multiple_non_pos_weight = 3.
#const non_positional_pref_weight = 10.
#const aggregate_group_by_raw_weight = 3.
#const x_y_raw_weight = 1.
#const log_weight = 1.
#const zero_weight = 1.
#const zero_size_weight = 3.
#const zero_positional_weight = 1.
#const zero_skew_weight = 5.
#const includes_zero_weight = 10.

#const only_row_column_weight = 2.
#const only_x_weight = 1.
#const orientation_binned_weight = 1.
#const orientation_discrete_weight = 1.
#const high_cardinality_ordinal_weight = 10.
#const high_cardinality_nominal_weight = 10.
#const horizontal_scrolling_weight = 20.
#const temporal_date_weight = 1.
#const quantitative_numbers_weight = 2.
#const position_entropy_weight = 2.
#const high_cardinality_size_weight = 1.
#const stack_opacity_weight = 5.
#const value_agg_weight = 1.
#const x_row_weight = 1.
#const y_row_weight = 1.
#const x_column_weight = 1.
#const y_column_weight = 1.
#const temporal_y_weight = 2.
#const c_d_column_weight = 5.

#const c_c_point_weight = 0.
#const c_c_line_weight = 20.
#const c_c_area_weight = 20.
#const c_c_text_weight = 2.
#const c_c_tick_weight = 5.

#const c_d_point_weight = 5.
#const c_d_bar_weight = 20.
#const c_d_line_weight = 20.
#const c_d_area_weight = 20.
#const c_d_text_weight = 50.
#const c_d_tick_weight = 0.

#const c_d_no_overlap_point_weight = 20.
#const c_d_no_overlap_bar_weight = 0.
#const c_d_no_overlap_line_weight = 20.
#const c_d_no_overlap_area_weight = 20.
#const c_d_no_overlap_text_weight = 30.
#const c_d_no_overlap_tick_weight = 25.

#const d_d_point_weight = 4.
#const d_d_text_weight = 7.
#const d_d_rect_weight = 8.

#const d_d_no_overlap_point_weight = 0.
#const d_d_no_overlap_text_weight = 3.
#const d_d_no_overlap_rect_weight = 2.

#const continuous_x_weight = 0.
#const continuous_y_weight = 0.
#const continuous_color_weight = 5.
#const continuous_opacity_weight = 30.
#const continuous_size_weight = 3.
#const continuous_text_weight = 20.

#const ordered_x_weight = 1.
#const ordered_y_weight = 0.
#const ordered_color_weight = 8.
#const ordered_opacity_weight = 30.
#const ordered_size_weight = 10.
#const ordered_text_weight = 32.
#const ordered_row_weight = 10.
#const ordered_column_weight = 10.

#const nominal_x_weight = 1.
#const nominal_y_weight = 0.
#const nominal_color_weight = 6.
#const nominal_shape_weight = 7.
#const nominal_text_weight = 8.
#const nominal_row_weight = 5.
#const nominal_column_weight = 6.
#const nominal_detail_weight = 20.

#const interesting_x_weight = 0.
#const interesting_y_weight = 1.
#const interesting_color_weight = 2.
#const interesting_opacity_weight = 3.
#const interesting_size_weight = 2.
#const interesting_shape_weight = 3.
#const interesting_text_weight = 6.
#const interesting_row_weight = 6.
#const interesting_column_weight = 7.
#const interesting_detail_weight = 20.

#const aggregate_count_weight = 0.
#const aggregate_count_sum = 1.
#const aggregate_mean_weight = 2.
#const aggregate_median_weight = 3.
#const aggregate_min_weight = 4.
#const aggregate_max_weight = 4.
#const aggregate_stdev_weight = 5.

#const value_point_weight = 0.
#const value_bar_weight = 0.
#const value_line_weight = 0.
#const value_area_weight = 0.
#const value_text_weight = 0.
#const value_tick_weight = 0.
#const value_rect_weight = 0.
#const summary_point_weight = 0.
#const summary_bar_weight = 0.
#const summary_line_weight = 0.
#const summary_area_weight = 0.
#const summary_text_weight = 0.
#const summary_tick_weight = 0.
#const summary_rect_weight = 0.

#const value_channel_x_weight = 0.
#const value_channel_y_weight = 0.
#const value_channel_color_weight = 0.
#const value_channel_opacity_weight = 0.
#const value_channel_size_weight = 0.
#const value_channel_shape_weight = 0.
#const value_channel_text_weight = 0.
#const value_channel_row_weight = 0.
#const value_channel_column_weight = 0.
#const value_channel_detail_weight = 0.

#const summary_channel_x_weight = 0.
#const summary_channel_weight = 0.
#const summary_channel_color_weight = 0.
#const summary_channel_opacity_weight = 0.
#const summary_channel_size_weight = 0.
#const summary_channel_shape_weight = 0.
#const summary_channel_text_weight = 0.
#const summary_channel_row_weight = 0.
#const summary_channel_column_weight = 0.
#const summary_channel_detail_weight = 0.

#const stack_zero_weight = 0.
#const stack_normalize_weight = 1.
