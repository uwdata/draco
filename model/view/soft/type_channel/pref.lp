% % @constraint Continuous on x channel.
% soft(type_channel,continuous_x,V,true) :- channel_fact(continuous,V,x).

% % @constraint Continuous on y channel.
% soft(type_channel,continuous_y,V,true) :- channel_fact(continuous,V,y).

% % @constraint Continuous on color channel.
% soft(type_channel,continuous_color,V,true) :- channel_fact(continuous,V,color).

% % @constraint Continuous on size channel.
% soft(type_channel,continuous_size,V,true) :- channel_fact(continuous,V,size).

% % @constraint Continuous on text channel.
% soft(type_channel,continuous_text,V,true) :- channel_fact(continuous,V,text).

% @constraint Ordered on x channel.
soft(type_channel,ordered_x,V,true) :- channel_fact(discrete,V,x), channel_fact(ordered,V,x).

% @constraint Ordered on y channel.
soft(type_channel,ordered_y,V,true) :- channel_fact(discrete,V,y), channel_fact(ordered,V,y).

% @constraint Ordered on color channel.
soft(type_channel,ordered_color,V,true) :- channel_fact(discrete,V,color), channel_fact(ordered,V,color).

% @constraint Ordered on size channel.
soft(type_channel,ordered_size,V,true) :- channel_fact(discrete,V,size), channel_fact(ordered,V,size).

% @constraint Ordered on text channel.
soft(type_channel,ordered_text,V,true) :- channel_fact(discrete,V,text), channel_fact(ordered,V,text).

% @constraint Ordered on row channel.
soft(type_channel,ordered_row,V,true) :- channel_fact(discrete,V,row), channel_fact(ordered,V,row).

% @constraint Ordered on column channel.
soft(type_channel,ordered_column,V,true) :- channel_fact(discrete,V,column), channel_fact(ordered,V,column).

% @constraint Nominal on x channel.
soft(type_channel,nominal_x,V,true) :- channel_fact(nominal,V,x).

% @constraint Nominal on y channel.
soft(type_channel,nominal_y,V,true) :- channel_fact(nominal,V,y).

% @constraint Nominal on color channel.
soft(type_channel,nominal_color,V,true) :- channel_fact(nominal,V,color).

% @constraint Nominal on shape channel.
soft(type_channel,nominal_shape,V,true) :- channel_fact(nominal,V,shape).

% @constraint Nominal on text channel.
soft(type_channel,nominal_text,V,true) :- channel_fact(nominal,V,text).

% @constraint Nominal on row channel.
soft(type_channel,nominal_row,V,true) :- channel_fact(nominal,V,row).

% @constraint Nominal on column channel.
soft(type_channel,nominal_column,V,true) :- channel_fact(nominal,V,column).

% @constraint Temporal on x channel.
soft(type_channel,temporal_x,V,true) :- channel_fact(temporal,V,x).

% @constraint Temporal on y channel.
soft(type_channel,temporal_y,V,true) :- channel_fact(temporal,V,y).

% @constraint Temporal on color channel.
soft(type_channel,temporal_color,V,true) :- channel_fact(temporal,V,color).

% @constraint Temporal on shape channel.
soft(type_channel,temporal_shape,V,true) :- channel_fact(temporal,V,shape).

% @constraint Temporal on text channel.
soft(type_channel,temporal_text,V,true) :- channel_fact(temporal,V,text).

% @constraint Temporal on row channel.
soft(type_channel,temporal_row,V,true) :- channel_fact(temporal,V,row).

% @constraint Temporal on column channel.
soft(type_channel,temporal_column,V,true) :- channel_fact(temporal,V,column).
