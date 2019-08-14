stripped_check(string_not_nominal,V) :- fieldtype(V,E,string), not type(V,E,nominal).
stripped_check(boolean_not_nominal,V) :- fieldtype(V,E,boolean), not type(V,E,nominal).
stripped_check(date_not_temporal,V) :- fieldtype(V,E,date), not type(V,E,temporal).
