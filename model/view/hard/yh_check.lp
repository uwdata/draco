yh_check(channels_q,V) :- field(V,E,(q1;q2)), channel(V,E,row).
yh_check(channels_n,V) :- field(V,E,n), channel(V,E,size).
