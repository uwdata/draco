#include "type_check.lp".
#include "encoding_check.lp".
#include "stack_check.lp".
#include "view_check.lp".
#include "yh_check.lp".

hard(type_check,NAME,V) :- type_check(NAME,V).
hard(type_check,NAME,V,X) :- type_check(NAME,V,X).

hard(encoding_check,NAME,V) :- encoding_check(NAME,V).
hard(encoding_check,NAME,V,X) :- encoding_check(NAME,V,X).

hard(stack_check,NAME,V) :- stack_check(NAME,V).
hard(view_check,NAME,V) :- view_check(NAME,V).

hard(yh_check,NAME,V) :- yh_check(NAME,V).

hard(TYPE,NAME,V,true) :- hard(TYPE,NAME,V).
