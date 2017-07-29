#!/usr/bin/env python3

from query import *
import json

def main():
    data = Data(file_name="data/ab.csv")
    bar_char_spec = Query(mark="bar", 
                          encoding=[Encoding(channel="x", field="a", ty="ordinal"), 
                                    Encoding(channel="y", field="b", ty="quantitative", aggregate="max")])
    task = Task(data, bar_char_spec)

    #print(task.to_asp())

    print(json.dumps(task.to_vegalite_obj(), sort_keys=True, indent=4))

if __name__ == '__main__':
    main()
