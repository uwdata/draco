a(1..3).
b(1..3).

{c(A,B): a(A), b(B)}.

% :- c(A,B), c(A,BB), B != BB.
% {c(A,B): b(B)} 1 :- a(A).
:- a(A), 2 { c(A,_) }.

#show c/2.
