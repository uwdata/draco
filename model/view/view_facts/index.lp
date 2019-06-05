#include "channel.lp".
#include "chart.lp".
#include "encoding.lp".

view_fact(channel,NAME,V,X) :- channel_fact(NAME,V,X).
view_fact(chart,NAME,V,true) :- chart_fact(NAME,V).
view_fact(encoding,NAME,V,X) :- encoding_fact(NAME,V,X).
