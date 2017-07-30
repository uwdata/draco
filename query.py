#!/usr/bin/env python3.6

import csv
import agate

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
        asp_str = "% ====== Data definitions ======\n" 
        asp_str += self.data.to_asp() + "\n\n"
        asp_str += "% ====== Query constraints ======\n" 
        asp_str += self.query.to_asp() 
        return asp_str


class Data(object):

    @staticmethod
    def load_from_file(file_name):
        data = Data()
        table = agate.Table.from_csv(file_name)

        # infer data types using agate library
        data.fields = []
        for i in range(len(table.column_names)):
            name = table.column_names[i]
            agate_type = table.column_types[i]
            type_name = "string"
            if isinstance(agate_type, agate.Text):
                type_name = "string"
            elif isinstance(agate_type, agate.Number):
                type_name = "number"
            elif isinstance(agate_type, agate.Boolean):
                type_name = "boolean"
            elif isinstance(agate_type, agate.Date):
                type_name = "date"
            elif isinstance(agate_type, agate.Datetime):
                type_name = "datetime"
            cardinality = len(set(table.columns.get(name)))
            data.fields.append(Field(name, type_name, cardinality))

        # store the table into a dict
        data.content = []
        for row in table.rows:
            row_obj = {}
            for j in range(len(row)):
                row_obj[data.fields[j].name] = str(row[j])
            data.content.append(row_obj)
        return data


    def __init__(self, fields=None, content=None):
        self.fields = fields
        self.content = content

    def to_vegalite_obj(self):
        return self.content

    def to_asp(self):
        return "\n".join([x.to_asp() for x in self.fields])

class Field(object):
    def __init__(self, name, ty, cardinality):
        # name of the field
        self.name = name
        # column data type, should be a string represented type, 
        # one of ("string", "number", "datetime", "date", "boolean")
        self.ty = ty
        # cardinality
        self.cardinality = cardinality

    def to_asp(self):
        return f"field_type({self.name}, {self.ty})"

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














