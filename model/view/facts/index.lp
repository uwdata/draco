#include "channel.lp".
#include "chart.lp".
#include "encoding.lp".

fact(channel,NAME,V,X) :- channel_fact(NAME,V,X).
fact(chart,NAME,V,X) :- chart_fact(NAME,V,X).
fact(encoding,NAME,V,X) :- encoding_fact(NAME,V,X).
