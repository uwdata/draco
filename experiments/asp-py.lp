#script (python)

from clingo import Number, Function

def args(term):
    return [(Number(i),elem) for i,elem in enumerate(term.arguments)]

def name(term):
    return Function(term.name)

#end.

% Here's a definition in some custom language we'd like to use:
%     name0: head0 <-- body0_a, body0_b, body0_c

% And here's a slight translation of this definition into Gringo syntax:
definition(name0,
     head0,
     conjuncts(
         body0_a,
         body0_b,
         body0_c)).


rule_id(R) :- definition(R,H,C).

rule_head(R,H) :- definition(R,H,C).

% unpack many terms from one conjuncts(...) construct
rule_conjunct(R,I,Elem) :-
    definition(R,H,C),
    (I,Elem) = @args(C),
    conjuncts = @name(C).
