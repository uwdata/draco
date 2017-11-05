from draco.spec import Field, Task, Encoding


class TestField():
    def test_number_to_asp(self):
        assert Field("foo", "number", 100).to_asp() == "fieldtype(foo,number).\ncardinality(foo,100).\n"

    def test_string_to_asp(self):
        assert Field("xxx", "string", 1).to_asp() == "fieldtype(xxx,string).\ncardinality(xxx,1).\n"

    def test_date_to_asp(self):
        assert Field("yyy", "datetime", 0).to_asp() == "fieldtype(yyy,datetime).\ncardinality(yyy,0).\n"


class TestEncoding():

    def test_full_to_asp(self):
        e = Encoding(channel="x", field="xx", ty="quantitative", aggregate="max", binning="3", scale=None, idx="e1")
        asp = "encoding(e1).\nchannel(e1,x).\nfield(e1,xx).\ntype(e1,q).\naggregate(e1,max).\nbin(e1,3).\n% 0 { scale(e1,B) : scale(B) } 1.\n"
        assert e.to_asp() == asp

    def test_channel_idx_to_asp(self):
        e = Encoding(channel="y", field=None, ty=None, aggregate=None, binning=None, scale=None, idx="e1")
        asp = "encoding(e1).\nchannel(e1,y).\n% 0 { field(e1,B) : field(B) } 1.\n% 0 { type(e1,B) : type(B) } 1.\n% 0 { aggregate(e1,B) : aggregate(B) } 1.\n% 0 { bin(e1,B) : bin(B) } 1.\n% 0 { scale(e1,B) : scale(B) } 1.\n"
        assert e.to_asp() == asp

    def test_only_idx_to_asp(self):
        e = Encoding(channel=None, field=None, ty=None, aggregate=None, binning=None, scale=None, idx="e1")
        asp = "encoding(e1).\n% 0 { channel(e1,B) : channel(B) } 1.\n% 0 { field(e1,B) : field(B) } 1.\n% 0 { type(e1,B) : type(B) } 1.\n% 0 { aggregate(e1,B) : aggregate(B) } 1.\n% 0 { bin(e1,B) : bin(B) } 1.\n% 0 { scale(e1,B) : scale(B) } 1.\n"
        assert e.to_asp() == asp

    def test_id_creation(self):
        Encoding.encoding_cnt = 0

        e = Encoding(channel=None, field=None, ty=None, aggregate=None, binning=None, scale=None)
        assert e.id == "e1"

        e = Encoding(channel=None, field=None, ty=None, aggregate=None, binning=None, scale=None)
        assert e.id == "e2"
