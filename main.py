#!/usr/bin/env python3

from meta import *

################ Task ###########################################

class Task(object):
    def __init__(self, table, query):
        self.table = table
        self.query = query


################ Viszualization Spec ############################


class Table(object):
    def __init__(self, columns):
        self.columns = columns


class Column(object):

    def __init__(self, name, raw_type, cardinality):
        # name of the field
        self.name = name

        # raw data type
        self.raw_type = raw_type
        
        # cardinality
        self.cardinality = cardinality


################ Viszualization Spec ############################


class Encoding(object):

    meta_spec = {
        # column from the table
        "column_reference" : NumericalAttr([0, 10]),
        # type: quantitative, ordinal, nominal
        "data_type": CategoricalAttr(["quantitative", "ordinal", "nominal"]),
        # aggregation type
        "aggregation": CategoricalAttr(["count", "max", "min", "avg"])
    }
    
    def __init__(self):
        self.spec = {
            "column_reference" : None,
            "data_type": None,
            "aggregation": None
        }


class Query(object):

    meta_spec = {
        # type of the mark: point, bar, line, area, text
        "mark_type" : CategoricalAttr(["point", "bar", "line", "area", "text"]),
        # x position
        "x": StructuralAttr("Encoding"),
        # y position
        "y": StructuralAttr("Encoding"),
        # color of the mark
        "color": StructuralAttr("Encoding"),
        # size of the mark
        "size": NumericalAttr([1, 100]),
        # shape of the mark, only for point
        "shape": CategoricalAttr(["circle", "triangle"]),
        # text of the mark, only for text mark
        "text": StringAttr(),
        # add columns to the group-by clause
        "detail": StringAttr()
    }

    def __init__(self):

        self.spec = {
            "mark_type" : None,
            "x": Encoding(),
            "y": Encoding(),
            "color": Encoding(),
            "size": None,
            "shape": None,
            "text": None,
            "detail": None
        }


def main():
    pass


if __name__ == '__main__':
    main()
