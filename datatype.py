
primitive_types = [int, float, str, bool]

### attr types

class BooleanAttr(object):

    def __init__(self, nullable=True):
        self.nullable = nullable

class NumericalAttr(object):

    def __init__(self, domain, nullable=True):
        self.domain = domain
        self.nullable = nullable

class StringAttr(object):

    def __init__(self, nullable=True):
        self.nullable = nullable

class CategoricalAttr(object):

    def __init__(self, domain, nullable=True):
        self.domain = domain
        self.nullable = nullable

class ClassAttr(object):

    def __init__(self, cls, nullable=True):
        self.cls = cls
        self.nullable = nullable
