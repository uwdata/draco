% @constraint Continuous on x channel.
soft(type_channel,continuous_x,V,true) :- channel_fact(continuous,V,x).

% @constraint Continuous on y channel.
soft(type_channel,continuous_y,V,true) :- channel_fact(continuous,V,y).

% @constraint Continuous on color channel.
soft(type_channel,continuous_color,V,true) :- channel_fact(continuous,V,color).

% @constraint Continuous on size channel.
soft(type_channel,continuous_size,V,true) :- channel_fact(continuous,V,size).

% @constraint Ordered on x channel.
soft(type_channel,ordered_x,V,true) :- channel_fact(discrete,V,x), channel_fact(ordered,V,x).

% @constraint Ordered on y channel.
soft(type_channel,ordered_y,V,true) :- channel_fact(discrete,V,y), channel_fact(ordered,V,y).

% @constraint Ordered on color channel.
soft(type_channel,ordered_color,V,true) :- channel_fact(discrete,V,color), channel_fact(ordered,V,color).

% @constraint Ordered on size channel.
soft(type_channel,ordered_size,V,true) :- channel_fact(discrete,V,size), channel_fact(ordered,V,size).

% @constraint Nominal on x channel.
soft(type_channel,nominal_x,V,true) :- channel_fact(nominal,V,x).

% @constraint Nominal on y channel.
soft(type_channel,nominal_y,V,true) :- channel_fact(nominal,V,y).

% @constraint Nominal on color channel.
soft(type_channel,nominal_color,V,true) :- channel_fact(nominal,V,color).

% @constraint Temporal on x channel.
soft(type_channel,temporal_x,V,true) :- channel_fact(temporal,V,x).

% @constraint Temporal on y channel.
soft(type_channel,temporal_y,V,true) :- channel_fact(temporal,V,y).

% @constraint Temporal on color channel.
soft(type_channel,temporal_color,V,true) :- channel_fact(temporal,V,color).
