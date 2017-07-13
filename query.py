#!/usr/bin/env python3

from datatype import *

class Task(object):
    def __init__(self, table, query):
        self.table = table
        self.query = query


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


class ChannelDef(object):

    meta_spec = {
        # column from the table
        "field" : NumericalAttr([0, 10]),
        # type: quantitative, ordinal, nominal
        "datatype": CategoricalAttr(["quantitative", "ordinal", "nominal"], nullable=False),
        # aggregation type
        "aggregation": CategoricalAttr(["count", "max", "min", "avg"]),
        # whether to bin or not
        "binning": BooleanAttr(nullable=False)
    }

    channel_def_cnt = 0
    
    def __init__(self, field, datatype, aggr=None, binning=None):
      self.field = field
      self.datatype = datatype
      self.aggr = aggr
      self.binning = binning


class Query(object):

    meta_spec = {
        # type of the mark: point, bar, line, area, text
        "mark_type" : CategoricalAttr(["point", "bar", "line", "area", "text"], nullable=False),
        # x position
        "x": ClassAttr(ChannelDef),
        # y position
        "y": ClassAttr(ChannelDef),
        # color of the mark
        "color": ClassAttr(ChannelDef),
        # size of the mark
        "size": ClassAttr(ChannelDef),
        # shape of the mark, only for point
        "shape": ClassAttr(ChannelDef),
        # text of the mark, only for text mark
        "text": ClassAttr(ChannelDef),
        # add columns to the group-by clause
        "detail": ClassAttr(ChannelDef)
    }

    def __init__(self, 
                 mark_type = None, 
                 x = None, 
                 y = None, 
                 color = None, 
                 size = None,
                 shape = None,
                 text = None,
                 detail = None):

        self.mark_type = mark_type
        self.x = x
        self.y = y
        self.color = color
        self.size = size
        self.shape = shape
        self.text = text
        self.detail = detail