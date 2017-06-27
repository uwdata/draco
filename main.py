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

    def gen_spec():
        # TODO: generate a json spec from an instance
        pass


################ Viszualization Spec ############################


class Encoding(object):

    meta_spec = {
        "column_reference" : NumericalAttr([0, 10]),
        "data_type": CategoricalAttr(["quantitative", "ordinal", "nominal"]),
        "aggregation": CategoricalAttr(["count", "max", "min", "avg"])
    }
    
    def __init__(self, column_reference, data_type, aggregation):
        # column from the table
        self.column_reference = column_reference

        # type: quantitative, ordinal, nominal
        self.data_type = data_type

        # aggregation type
        self.aggregation = aggregation
    
    def gen_spec():
        # TODO: generate a json spec from an instance
        pass



class Query(object):

    meta_spec = {
        "mark_type" : CategoricalAttr(["point", "bar", "line", "area", "text"]),
        "x": StructuralAttr("Encoding"),
        "y": StructuralAttr("Encoding"),
        "color": StructuralAttr("Encoding"),
        "size": NumericalAttr([1, 100]),
        "text": StringAttr(),
        "detail": StringAttr()
    }

    def __init__(self):
        # type of the mark: point, bar, line, area, text
        self.mark_type = None

        # === encoding definition ===

        # x position
        self.x = None

        # y position
        self.y = None

        # color of the mark
        self.color = None

        # size of the mark
        self.size = None

        # shape of the mark, only for point
        self.shape = None

        # text of the mark, only for text mark
        self.text = None

        # add columns to the group-by clause
        self.detail = None

    def gen_spec():
        # TODO: generate a json spec from an instance
        pass



def main():
    pass



if __name__ == '__main__':
    main()
