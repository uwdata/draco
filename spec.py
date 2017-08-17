#!/usr/bin/env python3

import csv
import agate
import json
import os

from pprint import pprint

# special token used by the spec
_null = "_null_"
_hole = "_??_"

def handle_special_value(v):
    # return a hole if the given value is not "??", else return the value.
    # this function is used in the parsing phase to convert "??" "null"
    #   into special symbol used by spec objects.
    return _hole if v == "??" else (_null if v == "null" else v)

class Task(object):

    def __init__(self, data, query):
        self.data = data
        self.query = query

    @staticmethod
    def load_from_vl_json(query_file, place_holder=_hole):
        """ load a task from a query spec
            Args:
                query_file: a CompassQL json file
                place_holder: whether unprovided spec are reprented as holes or null values
                    (this determine whether the solver would infer missing parts
                        or only infer properties specified by question marks)
            Returns:
                a Task object
        """
        raw_vl_obj = json.load(query_file)

        # load data from the file
        data = Data.load_from_vl_obj(raw_vl_obj["data"], path_prefix=os.path.dirname(query_file.name))

        # load query from the file
        mark = handle_special_value(raw_vl_obj["mark"]) if "mark" in raw_vl_obj else place_holder
        encodings_obj = raw_vl_obj["encoding"] if "encoding" in raw_vl_obj else {}
        query = Query.load_from_vl_obj(encodings_obj, mark)

        return Task(data, query)

    def to_vegalite_obj(self):
        """ generate a vegalite spec from the object """
        result = self.query.to_vegalite_obj()
        result["data"] = self.data.to_vegalite_obj()
        result["$schema"] = "https://vega.github.io/schema/vega-lite/v2.0.json"
        return result

    def to_vl_json(self):
        """ generate a vegalite json file form the object """
        return json.dumps(self.to_vegalite_obj(), sort_keys=True, indent=4)

    def to_asp(self):
        """ generate asp constraints from the object """
        asp_str = "% ====== Data definitions ======\n"
        asp_str += self.data.to_asp() + "\n\n"
        asp_str += "% ====== Query constraints ======\n"
        asp_str += self.query.to_asp()
        return asp_str


class Data(object):

    @staticmethod
    def load_from_vl_obj(vl_obj, path_prefix=None):
        """ Build a data object from a dict-represented vegalite object represting data"""
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
        """ Create a Data object from an agate table,
            data content and datatypes are based on how agate interprets them
        """
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
        return {"values": self.content}

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
        asp_str = f"fieldtype({self.name},{self.ty}).\n"
        asp_str += f"cardinality({self.name},{self.cardinality})."
        return asp_str


class Encoding(object):

    encoding_cnt = -1

    @staticmethod
    def gen_encoding_id():
        Encoding.encoding_cnt += 1
        return f"e{Encoding.encoding_cnt}"

    @staticmethod
    def load_from_vl_obj(vl_obj, place_holder=_hole):
        """ load encoding from a vl_obj
            Args:
                channel: the name of a channel
                vl_obj: a dict object representing channel encoding
                place_holder: values to the
            Returns:
                an encoding object
        """
        # get the field if it is in the object, otherwise generate a place holder symbol
        _get_field = lambda f: handle_special_value(vl_obj[f]) if f in vl_obj else place_holder

        return Encoding(_get_field("channel"), _get_field("field"), _get_field("type"),
                        _get_field("aggregate"), _get_field("bin"), _get_field("scale"))

    @staticmethod
    def parse_from_asp_result(encoding_id, encoding_props):

        _get_field = lambda props, target: props[target] if target in props else _null

        content = [_get_field(encoding_props, "channel"), 
                   _get_field(encoding_props, "field"), 
                   _get_field(encoding_props, "type"),
                   _get_field(encoding_props, "aggregate"),
                   _get_field(encoding_props, "bin"),
                   _get_field(encoding_props, "scale")]

        return Encoding(*content, encoding_id)


    def __init__(self, channel, field, ty, aggregate, binning, scale, idx=None):
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
        self.id = idx if idx is not None else Encoding.gen_encoding_id()


    def to_vegalite_obj(self):

        # we do not allow field and ty to be null
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
        # map an encoding type to a type name used in asp
        ty_to_asp_type = {
            "quantitative": "q",
            "ordinal": "o",
            "nominal": "n"
        }
        # if a property is a hole, generate a placeholder
        _wrap_props = lambda v: v if v is not _hole else "_"

        props = {
            "channel": self.channel,
            "field": self.field,
            # its type may be a _hole requesting for synthesis
            "type": ty_to_asp_type[self.ty] if self.ty in ty_to_asp_type else _hole,
            "aggregate": self.aggregate,
            "bin": self.binning,
            "scale": self.scale
        }

        constraints = []
        for k, v in props.items():
            if v is not _null:
                if v is not _hole:
                    s = f":- not {k}({self.id},{v})."
                else:
                    s = f"0 {{ {k}({self.id},B) : {k}(B) }} 1."
                constraints.append(s)

        return f"encoding({self.id}).\n" + "\n".join(constraints)
        #return f":- not 1 = { encoding(E) {", ".join(constraint) if len(constraint) else ""} }."


class Query(object):

    def __init__(self, mark, encodings=[]):
        # channels include "x", "y", "color", "size", "shape", "text", "detail"
        self.mark = mark
        self.encodings = encodings

    @staticmethod
    def load_from_vl_obj(vl_obj, mark):
        encodings = []
        for encoding_obj in vl_obj:
            encodings.append(Encoding.load_from_vl_obj(encoding_obj))
        return Query(mark, encodings)

    @staticmethod
    def parse_from_asp_result(raw_str_list):
        encodings = []
        mark = None

        raw_encoding_props = {}

        for s in raw_str_list:
            if s.startswith("mark"):
                mark = s[s.index("(") + 1 : s.index(")")]
            else:
                head = s[:s.index("(")]
                body = s[s.index("(") + 1: s.index(")")].split(",")
                encoding_id = body[0]

                # collect encoding properties
                if encoding_id not in raw_encoding_props:
                    raw_encoding_props[encoding_id] = {}
                raw_encoding_props[encoding_id][head] = body[1]

        # generate encoding objects from each collected encodings
        for k, v in raw_encoding_props.items():
            encodings.append(Encoding.parse_from_asp_result(k, v))
                
        return Query(mark, encodings)

    def to_vegalite_obj(self):
        query = {}
        query["mark"] = self.mark
        query["encoding"] = {}
        for e in self.encodings:
            query["encoding"][e.channel] = e.to_vegalite_obj()
        return query

    def to_asp(self):
        # the asp constrain comes from both mark and encodings
        prog = f":- not mark({self.mark}).\n"
        prog += "\n".join(map(lambda e: e.to_asp(), self.encodings))
        return prog
