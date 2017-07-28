#!/usr/bin/env python3.6

from datatype import *
import csv

def asp_prop(s):
    return s or '_'

class Task(object):
    
    def __init__(self, data, query):
        self.data = data
        self.query = query

    def to_vegalite_obj(self):
        result = self.query.to_vegalite_obj()
        result["data"] = self.data.to_vegalite_obj()
        #result["$schema"] = "https://vega.github.io/schema/vega-lite/v2.0.json"
        return result

    def to_asp(self):
        return self.query.to_asp()


class Data(object):
    def __init__(self, columns=None, file_name=None):
        self.columns = columns
        self.file_name = file_name

    def to_vegalite_obj(self):
        data = {}
        #data["url"] = self.url
        reader = csv.DictReader(open(self.file_name))
        data["values"] = [v for v in reader]
        return data


class Column(object):
    def __init__(self, name, raw_type, cardinality):
        # name of the field
        self.name = name
        # raw data type
        self.raw_type = raw_type
        # cardinality
        self.cardinality = cardinality


class Encoding(object):
    
    def __init__(self, channel, field, ty, aggregate=None, binning=None):
        """ Create a channel:
            Args:
                field: a string refering to a column in the table
                ty: type of the channel, one of "quantitative", "ordinal", "nominal"
                aggregate: what aggregation function to use on the channel
                binning: binning or not
        """
        self.channel = channel
        self.field = field 
        self.ty = ty
        self.aggregate = aggregate
        self.binning = binning

    def to_vegalite_obj(self):
        encoding = {}
        encoding["field"] = self.field
        encoding["type"] = self.ty
        if self.aggregate is not None:
            encoding["aggregate"] = self.aggregate
        if self.binning is not None:
            encoding["bin"] = self.binning
        return encoding

    def to_asp(self):
        ty_to_asp_type = {
            "quantitative": "q",
            "ordinal": "o",
            "nominal": "n"
        }
        props = [self.channel, self.field, ty_to_asp_type[self.ty]]
        return f":- not encoding({','.join(map(asp_prop, props))}).\n"


class Query(object):

    def __init__(self, mark=None, encoding=[]):
        # channels include "x", "y", "color", "size", "shape", "text", "detail"
        self.mark = mark
        self.encoding = encoding

    def to_vegalite_obj(self):
        query = {}
        query["mark"] = self.mark
        query["encoding"] = {}
        for e in self.encoding:
            query["encoding"][e.channel] = e.to_vegalite_obj()
        return query

    def to_asp(self):
        prog = ""

        if self.mark:
            prog += f":- mark({self.mark}).\n"


        for e in self.encoding:
            prog += e.to_asp()

        return prog














