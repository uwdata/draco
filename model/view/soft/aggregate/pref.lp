% @constraint Count as aggregate op.
soft(aggregate,count,V,E) :- aggregate(V,E,count).

% @constraint Sum as aggregate op.
soft(aggregate,sum,V,E) :- aggregate(V,E,sum).

% @constraint Mean as aggregate op.
soft(aggregate,mean,V,E) :- aggregate(V,E,mean).
