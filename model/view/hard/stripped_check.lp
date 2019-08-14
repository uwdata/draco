stripped_check(string_not_nominal,V) :- field(V,E,F), fieldtype(F,string), not type(V,E,nominal).
stripped_check(boolean_not_nominal,V) :- field(V,E,F), fieldtype(F,boolean), not type(V,E,nominal).
stripped_check(date_not_temporal,V) :- field(V,E,F), fieldtype(F,date), not type(V,E,temporal).
