#!/usr/bin/env python3

from query import *

def main():
    bar_char_spec = Query(mark_type="bar", 
                          x=ChannelDef(field=1, datatype="ordinal"), 
                          y=ChannelDef(field=2, datatype="quantitative"))

if __name__ == '__main__':
    main()
