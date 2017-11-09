"""
Tasks, Encoding, and Query helper classes for draco.
"""

import json
import os
from collections import defaultdict

import agate


NULL = "NULL_"    # I don't want this property
HOLE = "_??_"      # I want a value for this property
# Use `None` for "I didn't specify this and don't care"

def handle_special_value(v):
    # return a hole if the given value is not "??", else return the value.
    # this function is used in the parsing phase to convert "??" "null"
    #   into special symbol used by spec objects.
    return HOLE if v == "??" else (NULL if v == "null" else v)

class Task():

    def __init__(self, data, query):
        self.data = data
        self.query = query

    @staticmethod
    def load_from_json(query_file, place_holder=HOLE):
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
        data = Data.load_from_obj(raw_vl_obj["data"], path_prefix=os.path.dirname(query_file.name))

        # load query from the file
        mark = handle_special_value(raw_vl_obj["mark"]) if "mark" in raw_vl_obj else place_holder
        encodings_obj = raw_vl_obj["encoding"] if "encoding" in raw_vl_obj else []

        query = Query.load_from_obj(encodings_obj, mark)

        return Task(data, query)

    def to_vegalite_obj(self):
        """ generate a vegalite spec from the object """
        result = self.query.to_vegalite_obj()
        result["data"] = self.data.to_vegalite_obj()
        result["$schema"] = "https://vega.github.io/schema/vega-lite/v2.0.json"
        return result

    def to_vegalite_json(self):
        """ generate a vegalite json file form the object """
        return json.dumps(self.to_vegalite_obj(), sort_keys=True, indent=4)

    def to_asp(self):
        """ generate asp constraints from the object """
        asp_str = "% ====== Data definitions ======\n"
        asp_str += self.data.to_asp() + "\n\n"
        asp_str += "% ====== Query constraints ======\n"
        asp_str += self.query.to_asp()
        return asp_str


class Data():

    @staticmethod
    def load_from_obj(obj, path_prefix=None):
        """ Build a data object from a dict-represented
            vegalite object represting data"""
        if "url" in obj:
            # load data from url
            file_path = obj["url"]
            if path_prefix is not None:
                file_path = os.path.join(path_prefix, file_path)
            return Data.load_from_csv(file_path)
        else:
            # a dict represented data already included in the file
            return Data.from_agate_table(agate.Table.from_object(obj["values"]))

    @staticmethod
    def load_from_csv(filename):
        """ load data form a csv file """
        table = agate.Table.from_csv(filename)
        dt = Data.from_agate_table(table)
        dt.url = filename
        return dt

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
                type_name = "date" # take care!
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

    def __init__(self, fields=None, content=None, url=None):
        self.fields = fields
        self.content = content
        self.url = url

    def to_vegalite_obj(self):
        if self.url :
            return {"url": self.url}
        else:
            return {"values": self.content}

    def to_asp(self):
        return "\n".join([x.to_asp() for x in self.fields])


class Field():

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
        asp_str += f"cardinality({self.name},{self.cardinality}).\n"
        return asp_str


class Encoding():

    encoding_cnt = 0

    @staticmethod
    def gen_encoding_id():
        enc = f"e{Encoding.encoding_cnt}"
        Encoding.encoding_cnt += 1
        return enc

    @staticmethod
    def load_from_obj(obj):
        """ load encoding from a dict object representing the spec content
            Args:
                obj: a dict object representing channel encoding
            Returns:
                an encoding object
        """
        # get the field if it is in the object, otherwise generate a place holder symbol
        def _get_field(f):
            if f in obj:
                # for fields specified by the user, we want to add to the encoding
                return handle_special_value(obj[f])
            else:
                # if the user didn't a field for the encoding,
                # we use None (See comment in the front of the file)
                return None

        return Encoding(_get_field("channel"), _get_field("field"), _get_field("type"),
                        _get_field("aggregate"), _get_field("bin"))

    @staticmethod
    def parse_from_answer(encoding_id, encoding_props):
        _get_field = lambda props, target: props[target] if target in props else None

        content = [_get_field(encoding_props, "channel"),
                   _get_field(encoding_props, "field"),
                   _get_field(encoding_props, "type"),
                   _get_field(encoding_props, "aggregate"),
                   _get_field(encoding_props, "bin")]

        return Encoding(*content, encoding_id)


    def __init__(self, channel, field, ty, aggregate, binning, idx=None):
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
        self.id = idx if idx is not None else Encoding.gen_encoding_id()


    def to_vegalite_obj(self):
        encoding = {}
        if self.field:
            encoding["field"] = self.field
        if self.ty:
            encoding["type"] = self.ty
        if self.aggregate:
            encoding["aggregate"] = self.aggregate
        if self.binning:
            encoding["bin"] = {"maxbins" : int(self.binning)}

        return encoding

    def to_asp(self):
        # if a property is a hole, generate a placeholder
        _wrap_props = lambda v: v if v is not HOLE else "_"

        props = {
            "channel": self.channel,
            "field": self.field,
            # its type may be a NULL requesting for synthesis
            "type": self.ty,
            "aggregate": self.aggregate,
            "bin": self.binning
        }

        constraints = []
        for k, v in props.items():
            if v is NULL:
                s = f":- {k}({self.id},_)."
            elif v is HOLE:
                s = f":- not {k}({self.id},_)."
            elif v is None:
                s = f"% 0 {{ {k}({self.id},B) : {k}(B) }} 1."
            else:
                s = f"{k}({self.id},{v})."

            constraints.append(s)

        return f"encoding({self.id}).\n" + "\n".join(constraints) + "\n"
        #return f":- not 1 = { encoding(E) {", ".join(constraint) if len(constraint) else ""} }."


class Query():

    def __init__(self, mark, encodings=[]):
        # channels include "x", "y", "color", "size", "shape", "text", "detail"
        self.mark = mark
        self.encodings = encodings

    @staticmethod
    def load_from_obj(vl_obj, mark):
        encodings = []
        for encoding_obj in vl_obj:
            encodings.append(Encoding.load_from_obj(encoding_obj))
        return Query(mark, encodings)

    @staticmethod
    def parse_from_answer(clyngor_answer):
        encodings = []
        mark = None

        raw_encoding_props = defaultdict(dict)

        for (head, body), in clyngor_answer:
            if head == "mark":
                mark = body[0]
            else:
                # collect encoding properties
                raw_encoding_props[body[0]][head] = body[1] if len(body) > 1 else True

        # generate encoding objects from each collected encodings
        for k, v in raw_encoding_props.items():
            encodings.append(Encoding.parse_from_answer(k, v))

        return Query(mark, encodings)

    def to_vegalite_obj(self):
        query = {}
        query["mark"] = self.mark
        query["encoding"] = {}
        for e in self.encodings:
            query["encoding"][e.channel] = e.to_vegalite_obj()
        return query

    def to_asp(self):
        # the asp constraint comes from both mark and encodings

        prog = ""

        if self.mark != HOLE and self.mark != NULL:
            prog += f"mark({self.mark}).\n\n"

        prog += "\n".join(map(lambda e: e.to_asp(), self.encodings))
        return prog
