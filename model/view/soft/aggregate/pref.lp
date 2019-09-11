% @constraint Count as aggregate op.
soft(aggregate,count,V,E) :- aggregate(V,E,count).

% @constraint Sum as aggregate op.
soft(aggregate,sum,V,E) :- aggregate(V,E,sum).

% @constraint Mean as aggregate op.
soft(aggregate,mean,V,E) :- aggregate(V,E,mean).

% @constraint Median as aggregate op.
soft(aggregate,median,V,E) :- aggregate(V,E,median).

% @constraint Min as aggregate op.
soft(aggregate,min,V,E) :- aggregate(V,E,min).

% @constraint Max as aggregate op.
soft(aggregate,max,V,E) :- aggregate(V,E,max).

% @constraint Standard Deviation as aggregate op.
soft(aggregate,stdev,V,E) :- aggregate(V,E,stdev).
