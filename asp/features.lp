% ====== Preferences ======

% prefer quantitative > ordinal > nominal

feature_term("type_q",E) :- type(E,quantitative).
feature_term("type_o",E) :- type(E,ordinal).
feature_term("type_n",E) :- type(E,nominal).

% prefer to use raw (no aggregate)
feature_term("aggregate",E) :- aggregate(E,_).

% prefer to use fewer encodings
feature_term("encoding",E) :- encoding(E).

% prefer not to use the same field multiple times
feature_term("same_field_2",F) :- field(F), { field(_,F) } = 2.
feature_term("same_field_3",F) :- field(F), { field(_,F) } = 3.
feature_term("same_field_4",F) :- field(F), { field(_,F) } = 4.
feature_term("same_field_gte5",F) :- field(F), { field(_,F) } >= 5.

% categorical color channel should not have too high cardinality
feature_term("categorical_cardinality",E) :- channel(E,color), type(E,nominal), cardinality(E,C), C > 20.

% shape channel should not have too high cardinality
feature_term("shape_cardinality",E) :- channel(E,shape), cardinality(E,C), C > 6.

% numbers should not be nominal
feature_term("number_nominal",E) :- type(E,nominal), field(E,F), fieldtype(F,number).

% bar and tick should not use size
feature_term("bar_size"):- mark(bar), channel(_,size).

feature_term("tick_size"):- mark(tick), channel(_,size).

% binned quantitative field should not have too low cardinality
feature_term("bin_cardinality",E) :- type(E,quantitative), bin(E,_), cardinality(E,C), C < 15.

% prefer quantitative for bin
feature_term("quant_bin",E) :- bin(E,_), type(E,quantitative).

% aggregate should also have a dimension
feature_term("agg_dim"):- aggregate(_,_), not dimension(_).

% plots with only ordinal, binned q, or t with time unit should add count
feature_term("add_count"):- not not dimension(_), not aggregate(_,count).

% don"t use bar, line, or area for raw data as it leads to occulusion
feature_term("bar_raw"):- mark(bar), not aggregate(_,_).

feature_term("line_raw"):- mark(line), not aggregate(_,_).

feature_term("area_raw"):- mark(area), not aggregate(_,_).

% prefer not to use multiple non-positional encoding channels
feature_term("multiple_non_pos"):- {channel(_,C): non_positional(C)} > 1.

% prefer not to use non-positional channels until all positional channels are used
feature_term("non_positional_pref"):- channel(_,C), non_positional(C), not channel(_,(x;y)).

% aggregate plots should not use raw continuous as group by
feature_term("aggregate_group_by_raw",E) :- aggregate(_,_), type(E,quantitative), not bin(E,_), not aggregate(E,_).

% prefer not to use vertical for dot plot
feature_term("vertical_dot"):- channel(_,y), not channel(_,C), C != y, channel(C), not mark(bar).

% prefer not to use plot with both x and y dimension and no aggregate
feature_term("x_y_raw"):- channel(EX,x), dimension(EX), channel(EY,y), dimension(EY), not aggregate(_,_).

% prefer not to use log scale
feature_term("log",E) :- log(E).

% prefer to include zero
feature_term("zero",E) :- zero(E).

% prefer not to use x and y for measures with high cardinality and low entropy without aggregation because the points will overlap
feature_term("position_entropy", E) :- channel(E,(x;y)), measure(E), cardinality(E,C), C > 100, entropy(E,EN), EN <= 1, not aggregate(E,_).

% ====== Rankings ======

% measure by measure
is_m_m :- channel_meas(x), channel_meas(y).

feature_term("m_m_point"):- is_m_m, mark(point).
feature_term("m_m_bar"):- is_m_m, mark(bar).
feature_term("m_m_line"):- is_m_m, mark(line).
feature_term("m_m_area"):- is_m_m, mark(area).
feature_term("m_m_rule"):- is_m_m, mark(rule).
feature_term("m_m_text"):- is_m_m, mark(text).
feature_term("m_m_tick"):- is_m_m, mark(tick).
feature_term("m_m_rect"):- is_m_m, mark(rect).

% measure by dimension
is_m_d :- channel_meas(x), channel_dim(y).
is_m_d :- channel_meas(y), channel_dim(x).

feature_term("m_d_point"):- is_m_d, mark(point).
feature_term("m_d_bar"):- is_m_d, mark(bar).
feature_term("m_d_line"):- is_m_d, mark(line).
feature_term("m_d_area"):- is_m_d, mark(area).
feature_term("m_d_rule"):- is_m_d, mark(rule).
feature_term("m_d_text"):- is_m_d, mark(text).
feature_term("m_d_tick"):- is_m_d, mark(tick).
feature_term("m_d_rect"):- is_m_d, mark(rect).

% dimension by dimension
is_d_d :- channel_dim(x), channel_dim(y).

feature_term("d_d_point"):- is_d_d, mark(point).
feature_term("d_d_bar"):- is_d_d, mark(bar).
feature_term("d_d_line"):- is_d_d, mark(line).
feature_term("d_d_area"):- is_d_d, mark(area).
feature_term("d_d_rule"):- is_d_d, mark(rule).
feature_term("d_d_text"):- is_d_d, mark(text).
feature_term("d_d_tick"):- is_d_d, mark(tick).
feature_term("d_d_rect"):- is_d_d, mark(rect).

% channel rankings à la APT

feature_term("measure_x") :- channel(E,x), measure(E).
feature_term("measure_y") :- channel(E,y), measure(E).
feature_term("measure_color") :- channel(E,color), measure(E).
feature_term("measure_opacity") :- channel(E,opacity), measure(E).
feature_term("measure_size") :- channel(E,size), measure(E).
feature_term("measure_shape") :- channel(E,shape), measure(E).
feature_term("measure_text") :- channel(E,text), measure(E).
feature_term("measure_row") :- channel(E,row), measure(E).
feature_term("measure_column") :- channel(E,column), measure(E).

feature_term("ordered_x") :- channel(E,x), dimension(E), not type(E,nominal).
feature_term("ordered_y") :- channel(E,y), dimension(E), not type(E,nominal).
feature_term("ordered_color") :- channel(E,color), dimension(E), not type(E,nominal).
feature_term("ordered_opacity") :- channel(E,opacity), dimension(E), not type(E,nominal).
feature_term("ordered_size") :- channel(E,size), dimension(E), not type(E,nominal).
feature_term("ordered_shape") :- channel(E,shape), dimension(E), not type(E,nominal).
feature_term("ordered_text") :- channel(E,text), dimension(E), not type(E,nominal).
feature_term("ordered_row") :- channel(E,row), dimension(E), not type(E,nominal).
feature_term("ordered_column") :- channel(E,column), dimension(E), not type(E,nominal).

feature_term("nominal_x") :- channel(E,x), type(E,nominal).
feature_term("nominal_y") :- channel(E,y), type(E,nominal).
feature_term("nominal_color") :- channel(E,color), type(E,nominal).
feature_term("nominal_opacity") :- channel(E,opacity), type(E,nominal).
feature_term("nominal_size") :- channel(E,size), type(E,nominal).
feature_term("nominal_shape") :- channel(E,shape), type(E,nominal).
feature_term("nominal_text") :- channel(E,text), type(E,nominal).
feature_term("nominal_row") :- channel(E,row), type(E,nominal).
feature_term("nominal_column") :- channel(E,column), type(E,nominal).
