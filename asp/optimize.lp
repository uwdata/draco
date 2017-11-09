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
:~ aggregate(_,_). [agg_weight]

% prefer to use fewer encodings
#const encoding_weight = 6.
:~ encoding(E). [encoding_weight,E]

% prefer not to use the same field multiple times
#const same_field_weight = 10.
:~ { field(E,_) } = K, P = (K - 1) * same_field_weight, encoding(E), K > 1. [P,E]

% categorical color channel should not have too high cardinality
:~ channel(E,color), type(E,nominal), cardinality(E,C), C > 20. [5,E]

% shape channel should not have too high cardinality
:~ channel(E,shape), cardinality(E,C), C > 6. [5,E]

% numbers should not be nominal
:~ type(E,nominal), field(E,F), fieldtype(F,number). [2,E]

% bar and tick should not use size
:~ mark(bar;tick), channel(_,size). [5]

% binned quantitative field should not have too low cardinality
:~ type(E,quantitative), bin(E,_), cardinality(E,C), C < 15. [5,E]

% prefer quantitative for bin
:~ bin(E,_), type(E,quantitative). [1]

% aggregate should also have a dimension
:~ aggregate(_,_), not dimension(_). [2]

% plots with only ordinal, binned q, or t with time unit should add count
:~ not not dimension(_), not aggregate(_,count). [20]

% don't use bar, line, or area for raw data as it leads to occulusion
:~ mark(bar;line;area), not aggregate(_,_). [2]

% prefer not to use multiple non-positional encoding channels
#const multiple_non_pos_weight = 3.
:~ {channel(_,C): non_positional(C)} > 1. [multiple_non_pos_weight]

% prefer not to use non-positional channels until all positional channels are used
#const non_positional_pref_weight = 10.
:~ channel(_,C), non_positional(C), not channel(_,(x;y)). [non_positional_pref_weight]

% aggregate plots should not use raw continuous as group by
:~ aggregate(_,_), type(E,quantitative), not aggregate(E,_). [1]

% prefer not to use vertical for dot plot
:~ channel(_,y), not channel(_,C), C != y, channel(C), not mark(bar). [5]

% prefer not to use plot with both x and y dimension and no aggregate
:~ channel(EX,x), dimension(EX), channel(EY,y), dimension(EY), not aggregate(_,_). [2]

% prefer not to use log scale
:~ log(E), encoding(E). [1,E]

% prefer to include zero
:~ zero(E), encoding(E). [-1,E]


% ====== Rankings ======

% measure by measure
is_m_m :- channel_meas(x), channel_meas(y).

:~ is_m_m, mark(point). [0]
:~ is_m_m, mark(bar). [20]
:~ is_m_m, mark(line). [20]
:~ is_m_m, mark(area). [20]
:~ is_m_m, mark(rule). [25]
:~ is_m_m, mark(text). [2]
:~ is_m_m, mark(tick). [5]
:~ is_m_m, mark(rect). [10]

% measure by dimension
is_m_d :- channel_meas(x), channel_dim(y).
is_m_d :- channel_meas(y), channel_dim(x).

:~ is_m_d, mark(point). [0]
:~ is_m_d, mark(bar). [20]
:~ is_m_d, mark(line). [20]
:~ is_m_d, mark(area). [20]
:~ is_m_d, mark(rule). [25]
:~ is_m_d, mark(text). [50]
:~ is_m_d, mark(tick). [10]
:~ is_m_d, mark(rect). [20]

% dimension by dimension
is_d_d :- channel_dim(x), channel_dim(y).

:~ is_d_d, mark(point). [0]
:~ is_d_d, mark(bar). [20]
:~ is_d_d, mark(line). [20]
:~ is_d_d, mark(area). [20]
:~ is_d_d, mark(rule). [25]
:~ is_d_d, mark(text). [1]
:~ is_d_d, mark(tick). [10]
:~ is_d_d, mark(rect). [0]
