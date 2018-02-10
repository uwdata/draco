import unittest

from draco.spec import Data, Encoding, Field, Task


class TestField():
    def test_number_to_asp(self):
        assert Field('foo', 'number', 100).to_asp() == 'fieldtype(foo,number).\ncardinality(foo,100).\n'

    def test_string_to_asp(self):
        assert Field('xxx', 'string', 1).to_asp() == 'fieldtype(xxx,string).\ncardinality(xxx,1).\n'

    def test_date_to_asp(self):
        assert Field('yyy', 'datetime', 0).to_asp() == 'fieldtype(yyy,datetime).\ncardinality(yyy,0).\n'


class TestData():
    def test_to_asp(self):
        assert Data([Field('foo', 'number', '10')], 42).to_asp() == 'data_size(42).\n\nfieldtype(foo,number).\ncardinality(foo,10).\n'


class TestEncoding():
    @unittest.skip("@chenglong")
    def test_construct_with_bin(self):
        e = Encoding(channel='x', field='xx', ty='quantitative', binning='??')
        assert e.binning == '??'

        asp = 'encoding(e0).\nchannel(e0,x).\nfield(e0,xx).\ntype(e0,quantitative).\n0 { bin(e0,_) } 1.%0 { log(e1) } 1\n.zero(e0).\n'
        assert e.to_asp() == asp

    def test_full_to_asp(self):
        e = Encoding(channel='x', field='xx', ty='quantitative', aggregate='max', binning='3', log_scale=True, zero=False, idx='e1')
        asp = 'encoding(e1).\nchannel(e1,x).\nfield(e1,xx).\ntype(e1,quantitative).\naggregate(e1,max).\nbin(e1,3).\nlog(e1).\n:- zero(e1).\n'
        assert e.to_asp() == asp

    def test_channel_idx_to_asp(self):
        e = Encoding(channel='y', field=None, ty=None, aggregate=None, binning=None, log_scale=None, zero=None, idx='e1')
        asp = 'encoding(e1).\nchannel(e1,y).\n%0 { log(e1) } 1.\n%0 { zero(e1) } 1.\n'
        assert e.to_asp() == asp

    def test_only_idx_to_asp(self):
        e = Encoding(channel=None, field=None, ty=None, aggregate=None, binning=None, log_scale=None, zero=None, idx='e1')
        asp = 'encoding(e1).\n%0 { log(e1) } 1.\n%0 { zero(e1) } 1.\n'
        assert e.to_asp() == asp

    def test_id_creation(self):
        Encoding.encoding_cnt = 0

        e = Encoding(channel=None, field=None, ty=None, aggregate=None, binning=None, log_scale=None, zero=None)
        assert e.id == 'e0'

        e = Encoding(channel=None, field=None, ty=None, aggregate=None, binning=None, log_scale=None, zero=None)
        assert e.id == 'e1'
