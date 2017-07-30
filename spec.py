#!/usr/bin/env python3

import csv
import agate
import json
import os

from enum import Enum
from pprint import pprint


# special token used by the spec
_null = "_null_"
_hole = "_??_"

class Task(object):
    
    def __init__(self, data, query):
        self.data = data
        self.query = query

    @staticmethod
    def load_from_vl_json(filename, place_holder=_hole):
        """ load a task from a vegalite spec """
        with open(filename) as f:    
            raw_vl_obj = json.load(f)
            
        # load data from the file
        data = Data.load_from_vl_obj(raw_vl_obj["data"], path_prefix=os.path.dirname(filename))

        # load query from the file
        mark = raw_vl_obj["mark"] if "mark" in raw_vl_obj else place_holder
        encodings_obj = raw_vl_obj["encoding"] if "encoding" in raw_vl_obj else {}
        query = Query.load_from_vl_obj(encodings_obj, mark)

        return Task(data, query)

    def to_vegalite_obj(self):
        """ generate a vegalite spec from a task object """
        result = self.query.to_vegalite_obj()
        result["data"] = self.data.to_vegalite_obj()
        #result["$schema"] = "https://vega.github.io/schema/vega-lite/v2.0.json"
        return result

    def to_vl_json(self):
        return json.dumps(self.to_vegalite_obj(), sort_keys=True, indent=4)

    def to_asp(self):
        asp_str = "% ====== Data definitions ======\n" 
        asp_str += self.data.to_asp() + "\n\n"
        asp_str += "% ====== Query constraints ======\n" 
        asp_str += self.query.to_asp() 
        return asp_str


class Data(object):

    @staticmethod
    def load_from_vl_obj(vl_obj, path_prefix=None):
        if "url" in vl_obj:
            # load data from url
            file_path = vl_obj["url"]
            if path_prefix is not None:
                file_path = os.path.join(path_prefix, file_path)
            return Data.load_from_csv(file_path)
        else:
            # a dict represented data already included in the file
            return Data.from_agate_table(agate.Table.from_object(vl_obj["values"]))

    @staticmethod
    def load_from_csv(filename):
        """ load data form a csv file """
        table = agate.Table.from_csv(filename)
        return Data.from_agate_table(table)

    @staticmethod
    def from_agate_table(agate_table):
        # from an agate table, prepare data content as well as datatype
        # infer data types using agate library
        data = Data()
        data.fields = []
        for i in range(len(agate_table.column_names)):
            name = agate_table.column_names[i]
            agate_type = agate_table.column_types[i]
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
            cardinality = len(set(agate_table.columns.get(name)))
            data.fields.append(Field(name, type_name, cardinality))

        # store the table into a dict
        data.content = []
        for row in agate_table.rows:
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
        return f"fieldtype({self.name},{self.ty}).\ncardinality({self.name},{self.cardinality})."


class Encoding(object):

    @staticmethod
    def load_from_vl_obj(channel, vl_obj, place_holder=_hole):
        """ load encoding from a vl_obj
            Args: 
                channel: the name of a channel
                vl_obj: a dict object representing channel encoding
                place_holder: values to the 
            Returns:
                an encoding object
        """
        _get_field = lambda f: vl_obj[f] if f in vl_obj else place_holder
        return Encoding(channel, _get_field("field"), _get_field("type"), 
                        _get_field("aggregate"), _get_field("bin"), _get_field("scale"))

    
    def __init__(self, channel, field, ty, aggregate, binning, scale):
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
        self.scale = scale

    def to_vegalite_obj(self):
        assert self.field is not _null
        assert self.ty is not _null 

        encoding = {}
        encoding["field"] = self.field
        encoding["type"] = self.ty
        if self.aggregate is not _null:
            encoding["aggregate"] = self.aggregate
        if self.binning is not _null:
            encoding["bin"] = self.binning
        if self.scale is not _null:
            encoding["scale"] = self.scale
        return encoding

    def to_asp(self):
        ty_to_asp_type = {
            "quantitative": "q",
            "ordinal": "o",
            "nominal": "n"
        }

        _wrap_props = lambda p: p if p is not _hole else "_"

        props = [self.channel, 
                 self.field, 
                 ty_to_asp_type[self.ty],
                 self.aggregate,
                 self.binning,
                 self.scale]
        return f":- not encoding({','.join(map(_wrap_props, props))}).\n"


class Query(object):

    def __init__(self, mark, encodings=[]):
        # channels include "x", "y", "color", "size", "shape", "text", "detail"
        self.mark = mark
        self.encodings = encodings

    @staticmethod
    def load_from_vl_obj(vl_obj, mark):
        encodings = []
        for channel, encoding_obj in vl_obj.items():
            encodings.append(Encoding.load_from_vl_obj(channel, encoding_obj))
        return Query(mark, encodings)

    def to_vegalite_obj(self):
        query = {}
        query["mark"] = self.mark
        query["encoding"] = {}
        for e in self.encodings:
            query["encoding"][e.channel] = e.to_vegalite_obj()
        return query

    def to_asp(self):
        prog = ""

        if self.mark:
            prog += f":- mark({self.mark}).\n"

        for e in self.encodings:
            prog += e.to_asp()

        return prog









