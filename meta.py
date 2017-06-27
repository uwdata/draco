


class BooleanAttr(object):
    def __init__(self):
        pass

class NumericalAttr(object):
    def __init__(self, domain):
        self.domain = domain

class StringAttr(object):
    def __init__(self):
        pass

class CategoricalAttr(object):
    def __init__(self, domain):
        self.domain = domain

class StructuralAttr(object):
    def __init__(self, name):
        self.name = name
