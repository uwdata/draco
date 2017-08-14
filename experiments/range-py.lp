#script (python)

def rng(a, b):
    return range(a.number, b.number+1)

#end.

p(1,3).
p(5,10).
rng(X,Y,@rng(X,Y)) :- p(X,Y).
