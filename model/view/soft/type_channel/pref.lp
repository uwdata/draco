%% READ VALUE

% @constraint Continuous on x channel.
soft(type_channel,continuous_x_read_value,V,true) :- channel_fact(continuous,V,x).

% @constraint Continuous on y channel.
soft(type_channel,continuous_y_read_value,V,true) :- channel_fact(continuous,V,y).

% @constraint Continuous on color channel.
soft(type_channel,continuous_color_read_value,V,true) :- channel_fact(continuous,V,color).

% @constraint Continuous on size channel.
soft(type_channel,continuous_size_read_value,V,true) :- channel_fact(continuous,V,size).

% @constraint Continuous on text channel.
soft(type_channel,continuous_text_read_value,V,true) :- channel_fact(continuous,V,text).

% @constraint Ordered on x channel.
soft(type_channel,ordered_x_read_value,V,true) :- channel_fact(discrete,V,x), channel_fact(ordered,V,x).

% @constraint Ordered on y channel.
soft(type_channel,ordered_y_read_value,V,true) :- channel_fact(discrete,V,y), channel_fact(ordered,V,y).

% @constraint Ordered on color channel.
soft(type_channel,ordered_color_read_value,V,true) :- channel_fact(discrete,V,color), channel_fact(ordered,V,color).

% @constraint Ordered on size channel.
soft(type_channel,ordered_size_read_value,V,true) :- channel_fact(discrete,V,size), channel_fact(ordered,V,size).

% @constraint Ordered on text channel.
soft(type_channel,ordered_text_read_value,V,true) :- channel_fact(discrete,V,text), channel_fact(ordered,V,text).

% @constraint Ordered on row channel.
soft(type_channel,ordered_row_read_value,V,true) :- channel_fact(discrete,V,row), channel_fact(ordered,V,row).

% @constraint Ordered on column channel.
soft(type_channel,ordered_column_read_value,V,true) :- channel_fact(discrete,V,column), channel_fact(ordered,V,column).

% @constraint Nominal on x channel.
soft(type_channel,nominal_x_read_value,V,true) :- channel_fact(nominal,V,x).

% @constraint Nominal on y channel.
soft(type_channel,nominal_y_read_value,V,true) :- channel_fact(nominal,V,y).

% @constraint Nominal on color channel.
soft(type_channel,nominal_color_read_value,V,true) :- channel_fact(nominal,V,color).

% @constraint Nominal on shape channel.
soft(type_channel,nominal_shape_read_value,V,true) :- channel_fact(nominal,V,shape).

% @constraint Nominal on text channel.
soft(type_channel,nominal_text_read_value,V,true) :- channel_fact(nominal,V,text).

% @constraint Nominal on row channel.
soft(type_channel,nominal_row_read_value,V,true) :- channel_fact(nominal,V,row).

% @constraint Nominal on column channel.
soft(type_channel,nominal_column_read_value,V,true) :- channel_fact(nominal,V,column).

% @constraint Temporal on x channel.
soft(type_channel,temporal_x_read_value,V,true) :- channel_fact(temporal,V,x).

% @constraint Temporal on y channel.
soft(type_channel,temporal_y_read_value,V,true) :- channel_fact(temporal,V,y).

% @constraint Temporal on color channel.
soft(type_channel,temporal_color_read_value,V,true) :- channel_fact(temporal,V,color).

% @constraint Temporal on shape channel.
soft(type_channel,temporal_shape_read_value,V,true) :- channel_fact(temporal,V,shape).

% @constraint Temporal on text channel.
soft(type_channel,temporal_text_read_value,V,true) :- channel_fact(temporal,V,text).

% @constraint Temporal on row channel.
soft(type_channel,temporal_row_read_value,V,true) :- channel_fact(temporal,V,row).

% @constraint Temporal on column channel.
soft(type_channel,temporal_column_read_value,V,true) :- channel_fact(temporal,V,column).


%% COMPARE VALUE

% @constraint Continuous on x channel.
soft(type_channel,continuous_x_compare_value,V,true) :- channel_fact(continuous,V,x).

% @constraint Continuous on y channel.
soft(type_channel,continuous_y_compare_value,V,true) :- channel_fact(continuous,V,y).

% @constraint Continuous on color channel.
soft(type_channel,continuous_color_compare_value,V,true) :- channel_fact(continuous,V,color).

% @constraint Continuous on size channel.
soft(type_channel,continuous_size_compare_value,V,true) :- channel_fact(continuous,V,size).

% @constraint Continuous on text channel.
soft(type_channel,continuous_text_compare_value,V,true) :- channel_fact(continuous,V,text).

% @constraint Ordered on x channel.
soft(type_channel,ordered_x_compare_value,V,true) :- channel_fact(discrete,V,x), channel_fact(ordered,V,x).

% @constraint Ordered on y channel.
soft(type_channel,ordered_y_compare_value,V,true) :- channel_fact(discrete,V,y), channel_fact(ordered,V,y).

% @constraint Ordered on color channel.
soft(type_channel,ordered_color_compare_value,V,true) :- channel_fact(discrete,V,color), channel_fact(ordered,V,color).

% @constraint Ordered on size channel.
soft(type_channel,ordered_size_compare_value,V,true) :- channel_fact(discrete,V,size), channel_fact(ordered,V,size).

% @constraint Ordered on text channel.
soft(type_channel,ordered_text_compare_value,V,true) :- channel_fact(discrete,V,text), channel_fact(ordered,V,text).

% @constraint Ordered on row channel.
soft(type_channel,ordered_row_compare_value,V,true) :- channel_fact(discrete,V,row), channel_fact(ordered,V,row).

% @constraint Ordered on column channel.
soft(type_channel,ordered_column_compare_value,V,true) :- channel_fact(discrete,V,column), channel_fact(ordered,V,column).

% @constraint Nominal on x channel.
soft(type_channel,nominal_x_compare_value,V,true) :- channel_fact(nominal,V,x).

% @constraint Nominal on y channel.
soft(type_channel,nominal_y_compare_value,V,true) :- channel_fact(nominal,V,y).

% @constraint Nominal on color channel.
soft(type_channel,nominal_color_compare_value,V,true) :- channel_fact(nominal,V,color).

% @constraint Nominal on shape channel.
soft(type_channel,nominal_shape_compare_value,V,true) :- channel_fact(nominal,V,shape).

% @constraint Nominal on text channel.
soft(type_channel,nominal_text_compare_value,V,true) :- channel_fact(nominal,V,text).

% @constraint Nominal on row channel.
soft(type_channel,nominal_row_compare_value,V,true) :- channel_fact(nominal,V,row).

% @constraint Nominal on column channel.
soft(type_channel,nominal_column_compare_value,V,true) :- channel_fact(nominal,V,column).

% @constraint Temporal on x channel.
soft(type_channel,temporal_x_compare_value,V,true) :- channel_fact(temporal,V,x).

% @constraint Temporal on y channel.
soft(type_channel,temporal_y_compare_value,V,true) :- channel_fact(temporal,V,y).

% @constraint Temporal on color channel.
soft(type_channel,temporal_color_compare_value,V,true) :- channel_fact(temporal,V,color).

% @constraint Temporal on shape channel.
soft(type_channel,temporal_shape_compare_value,V,true) :- channel_fact(temporal,V,shape).

% @constraint Temporal on text channel.
soft(type_channel,temporal_text_compare_value,V,true) :- channel_fact(temporal,V,text).

% @constraint Temporal on row channel.
soft(type_channel,temporal_row_compare_value,V,true) :- channel_fact(temporal,V,row).

% @constraint Temporal on column channel.
soft(type_channel,temporal_column_compare_value,V,true) :- channel_fact(temporal,V,column).


%% FIND MAX

% @constraint Continuous on x channel.
soft(type_channel,continuous_x_find_maximum,V,true) :- channel_fact(continuous,V,x).

% @constraint Continuous on y channel.
soft(type_channel,continuous_y_find_maximum,V,true) :- channel_fact(continuous,V,y).

% @constraint Continuous on color channel.
soft(type_channel,continuous_color_find_maximum,V,true) :- channel_fact(continuous,V,color).

% @constraint Continuous on size channel.
soft(type_channel,continuous_size_find_maximum,V,true) :- channel_fact(continuous,V,size).

% @constraint Continuous on text channel.
soft(type_channel,continuous_text_find_maximum,V,true) :- channel_fact(continuous,V,text).

% @constraint Ordered on x channel.
soft(type_channel,ordered_x_find_maximum,V,true) :- channel_fact(discrete,V,x), channel_fact(ordered,V,x).

% @constraint Ordered on y channel.
soft(type_channel,ordered_y_find_maximum,V,true) :- channel_fact(discrete,V,y), channel_fact(ordered,V,y).

% @constraint Ordered on color channel.
soft(type_channel,ordered_color_find_maximum,V,true) :- channel_fact(discrete,V,color), channel_fact(ordered,V,color).

% @constraint Ordered on size channel.
soft(type_channel,ordered_size_find_maximum,V,true) :- channel_fact(discrete,V,size), channel_fact(ordered,V,size).

% @constraint Ordered on text channel.
soft(type_channel,ordered_text_find_maximum,V,true) :- channel_fact(discrete,V,text), channel_fact(ordered,V,text).

% @constraint Ordered on row channel.
soft(type_channel,ordered_row_find_maximum,V,true) :- channel_fact(discrete,V,row), channel_fact(ordered,V,row).

% @constraint Ordered on column channel.
soft(type_channel,ordered_column_find_maximum,V,true) :- channel_fact(discrete,V,column), channel_fact(ordered,V,column).

% @constraint Nominal on x channel.
soft(type_channel,nominal_x_find_maximum,V,true) :- channel_fact(nominal,V,x).

% @constraint Nominal on y channel.
soft(type_channel,nominal_y_find_maximum,V,true) :- channel_fact(nominal,V,y).

% @constraint Nominal on color channel.
soft(type_channel,nominal_color_find_maximum,V,true) :- channel_fact(nominal,V,color).

% @constraint Nominal on shape channel.
soft(type_channel,nominal_shape_find_maximum,V,true) :- channel_fact(nominal,V,shape).

% @constraint Nominal on text channel.
soft(type_channel,nominal_text_find_maximum,V,true) :- channel_fact(nominal,V,text).

% @constraint Nominal on row channel.
soft(type_channel,nominal_row_find_maximum,V,true) :- channel_fact(nominal,V,row).

% @constraint Nominal on column channel.
soft(type_channel,nominal_column_find_maximum,V,true) :- channel_fact(nominal,V,column).

% @constraint Temporal on x channel.
soft(type_channel,temporal_x_find_maximum,V,true) :- channel_fact(temporal,V,x).

% @constraint Temporal on y channel.
soft(type_channel,temporal_y_find_maximum,V,true) :- channel_fact(temporal,V,y).

% @constraint Temporal on color channel.
soft(type_channel,temporal_color_find_maximum,V,true) :- channel_fact(temporal,V,color).

% @constraint Temporal on shape channel.
soft(type_channel,temporal_shape_find_maximum,V,true) :- channel_fact(temporal,V,shape).

% @constraint Temporal on text channel.
soft(type_channel,temporal_text_find_maximum,V,true) :- channel_fact(temporal,V,text).

% @constraint Temporal on row channel.
soft(type_channel,temporal_row_find_maximum,V,true) :- channel_fact(temporal,V,row).

% @constraint Temporal on column channel.
soft(type_channel,temporal_column_find_maximum,V,true) :- channel_fact(temporal,V,column).


%% COMPARE AVERAGE

% @constraint Continuous on x channel.
soft(type_channel,continuous_x_compare_average,V,true) :- channel_fact(continuous,V,x).

% @constraint Continuous on y channel.
soft(type_channel,continuous_y_compare_average,V,true) :- channel_fact(continuous,V,y).

% @constraint Continuous on color channel.
soft(type_channel,continuous_color_compare_average,V,true) :- channel_fact(continuous,V,color).

% @constraint Continuous on size channel.
soft(type_channel,continuous_size_compare_average,V,true) :- channel_fact(continuous,V,size).

% @constraint Continuous on text channel.
soft(type_channel,continuous_text_compare_average,V,true) :- channel_fact(continuous,V,text).

% @constraint Ordered on x channel.
soft(type_channel,ordered_x_compare_average,V,true) :- channel_fact(discrete,V,x), channel_fact(ordered,V,x).

% @constraint Ordered on y channel.
soft(type_channel,ordered_y_compare_average,V,true) :- channel_fact(discrete,V,y), channel_fact(ordered,V,y).

% @constraint Ordered on color channel.
soft(type_channel,ordered_color_compare_average,V,true) :- channel_fact(discrete,V,color), channel_fact(ordered,V,color).

% @constraint Ordered on size channel.
soft(type_channel,ordered_size_compare_average,V,true) :- channel_fact(discrete,V,size), channel_fact(ordered,V,size).

% @constraint Ordered on text channel.
soft(type_channel,ordered_text_compare_average,V,true) :- channel_fact(discrete,V,text), channel_fact(ordered,V,text).

% @constraint Ordered on row channel.
soft(type_channel,ordered_row_compare_average,V,true) :- channel_fact(discrete,V,row), channel_fact(ordered,V,row).

% @constraint Ordered on column channel.
soft(type_channel,ordered_column_compare_average,V,true) :- channel_fact(discrete,V,column), channel_fact(ordered,V,column).

% @constraint Nominal on x channel.
soft(type_channel,nominal_x_compare_average,V,true) :- channel_fact(nominal,V,x).

% @constraint Nominal on y channel.
soft(type_channel,nominal_y_compare_average,V,true) :- channel_fact(nominal,V,y).

% @constraint Nominal on color channel.
soft(type_channel,nominal_color_compare_average,V,true) :- channel_fact(nominal,V,color).

% @constraint Nominal on shape channel.
soft(type_channel,nominal_shape_compare_average,V,true) :- channel_fact(nominal,V,shape).

% @constraint Nominal on text channel.
soft(type_channel,nominal_text_compare_average,V,true) :- channel_fact(nominal,V,text).

% @constraint Nominal on row channel.
soft(type_channel,nominal_row_compare_average,V,true) :- channel_fact(nominal,V,row).

% @constraint Nominal on column channel.
soft(type_channel,nominal_column_compare_average,V,true) :- channel_fact(nominal,V,column).

% @constraint Temporal on x channel.
soft(type_channel,temporal_x_compare_average,V,true) :- channel_fact(temporal,V,x).

% @constraint Temporal on y channel.
soft(type_channel,temporal_y_compare_average,V,true) :- channel_fact(temporal,V,y).

% @constraint Temporal on color channel.
soft(type_channel,temporal_color_compare_average,V,true) :- channel_fact(temporal,V,color).

% @constraint Temporal on shape channel.
soft(type_channel,temporal_shape_compare_average,V,true) :- channel_fact(temporal,V,shape).

% @constraint Temporal on text channel.
soft(type_channel,temporal_text_compare_average,V,true) :- channel_fact(temporal,V,text).

% @constraint Temporal on row channel.
soft(type_channel,temporal_row_compare_average,V,true) :- channel_fact(temporal,V,row).

% @constraint Temporal on column channel.
soft(type_channel,temporal_column_compare_average,V,true) :- channel_fact(temporal,V,column).

