from draco.spec import Field

import os

class TestField():
    def test_to_asp(self):
        f = Field("foo", "number", 100)
        assert f.to_asp() == "fieldtype(foo,number).\ncardinality(foo,100).\n"