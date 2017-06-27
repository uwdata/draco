#!/usr/bin/env python3


class Column:
    # name of the field
    name = None

    # raw data type
    raw_type = None

    # === simple stats ====
    
    # cardinality
    cardinality = None


class Encoding:
    # column from the table
    column = None

    # type: quantitative, ordinal, nominal
    data_type = None

    # aggregation type
    aggregation = None


class Query:
    # type of the mark: point, bar, line, area, text
    mark_type = None

    # === encoding definition ===
    
    # x position
    x = None

    # y position
    y = None

    # color of the mark
    color = None

    # size of the mark
    size = None

    # shape of the mark, only for point
    shape = None

    # text of the mark, only for text mark
    text = None

    # add columns to the group-by clause
    detail = None


def main():
    pass


if __name__ == '__main__':
    main()
