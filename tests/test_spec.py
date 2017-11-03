from draco.spec import Field, Task, Encoding

import os

class TestField():

    fields = [
        Field("foo", "number", 100),
        Field("xxx", "string", 1),
        Field("yyy", "datetime", 0)
    ]

    asp_strs = [
        "fieldtype(foo,number).\ncardinality(foo,100).\n",
        "fieldtype(xxx,string).\ncardinality(xxx,1).\n",
        "fieldtype(yyy,datetime).\ncardinality(yyy,0).\n"
    ]

    def test_to_asp(self):
        for i in range(len(TestField.fields)):
            assert TestField.fields[i].to_asp() == TestField.asp_strs[i]


class TestEncoding():

    encodings = [
        Encoding(channel="x", field="xx", ty="quantitative", aggregate="max", binning="3", scale=None, idx="e1"),
        Encoding(channel="y", field=None, ty=None, aggregate=None, binning=None, scale=None, idx="e1"),
        Encoding(channel=None, field=None, ty=None, aggregate=None, binning=None, scale=None, idx="e1")
    ]

    asp_strs = [
        "encoding(e1).\nchannel(e1,x).\nfield(e1,xx).\ntype(e1,q).\naggregate(e1,max).\nbin(e1,3).\n% 0 { scale(e1,B) : scale(B) } 1.\n",
        "encoding(e1).\nchannel(e1,y).\n% 0 { field(e1,B) : field(B) } 1.\n% 0 { type(e1,B) : type(B) } 1.\n% 0 { aggregate(e1,B) : aggregate(B) } 1.\n% 0 { bin(e1,B) : bin(B) } 1.\n% 0 { scale(e1,B) : scale(B) } 1.\n",
        "encoding(e1).\n% 0 { channel(e1,B) : channel(B) } 1.\n% 0 { field(e1,B) : field(B) } 1.\n% 0 { type(e1,B) : type(B) } 1.\n% 0 { aggregate(e1,B) : aggregate(B) } 1.\n% 0 { bin(e1,B) : bin(B) } 1.\n% 0 { scale(e1,B) : scale(B) } 1.\n"
    ]

    def test_to_asp(self):
        for i in range(len(TestEncoding.encodings)):
            assert TestEncoding.encodings[i].to_asp() == TestEncoding.asp_strs[i]                

