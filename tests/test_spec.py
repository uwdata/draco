from draco.spec import Data, Encoding, Field, Query


class TestField():
    def test_number_to_asp(self):
        assert Field('foo', 'number', 100, 0.3).to_asp() == 'fieldtype(foo,number).\ncardinality(foo,100).\nentropy(foo,3).\n'

    def test_string_to_asp(self):
        assert Field('xxx', 'string', 5).to_asp() == 'fieldtype(xxx,string).\ncardinality(xxx,5).\n'

    def test_date_to_asp(self):
        assert Field('yyy', 'datetime', 10).to_asp() == 'fieldtype(yyy,datetime).\ncardinality(yyy,10).\n'


class TestData():
    def test_to_asp(self):
        data = Data([Field('foo', 'number', 10, 0.4)], 42)

        assert data.to_asp() == 'num_rows(42).\n\nfieldtype(foo,number).\ncardinality(foo,10).\nentropy(foo,4).\n'

    def test_generate(self):
        data = Data(fields=[Field('foo', 'number', 10, 2.1, [1,2])])
        assert data.content == None
        data.fill_with_random_content()
        assert data.content != None


class TestEncoding():
    def test_construct_with_bin_wild(self):
        e = Encoding(channel='x', field='xx', ty='quantitative', binning='?', idx='e1')
        assert e.binning == '?'

        asp = 'encoding(e1).\nchannel(e1,x).\nfield(e1,xx).\ntype(e1,quantitative).\n1 = { bin(e1,P): binning(P) }.\n'
        assert e.to_asp() == asp

    def test_construct_with_bin_true(self):
        e = Encoding(channel='x', field='xx', ty='quantitative', binning=True, idx='e1')
        assert e.binning == True

        asp = 'encoding(e1).\nchannel(e1,x).\nfield(e1,xx).\ntype(e1,quantitative).\n1 = { bin(e1,P): binning(P) }.\n'
        assert e.to_asp() == asp

    def test_construct_with_bin_false(self):
        e = Encoding(channel='x', field='xx', ty='quantitative', binning=False, idx='e1')
        assert e.binning == False

        asp = 'encoding(e1).\nchannel(e1,x).\nfield(e1,xx).\ntype(e1,quantitative).\n:- bin(e1,_).\n'
        assert e.to_asp() == asp

    def test_construct_with_bin_value(self):
        e = Encoding(channel='x', field='xx', ty='quantitative', binning=16, idx='e1')
        assert e.binning == 16

        asp = 'encoding(e1).\nchannel(e1,x).\nfield(e1,xx).\ntype(e1,quantitative).\nbin(e1,16).\n'
        assert e.to_asp() == asp

    def test_full_to_asp(self):
        e = Encoding(channel='x', field='xx', ty='quantitative', aggregate='max', binning=3, log_scale=True, zero=False, stack='zero', idx='e1')
        asp = 'encoding(e1).\nchannel(e1,x).\nfield(e1,xx).\ntype(e1,quantitative).\naggregate(e1,max).\nstack(e1,zero).\nbin(e1,3).\nlog(e1).\n:- zero(e1).\n'
        assert e.to_asp() == asp

    def test_channel_idx_to_asp(self):
        e = Encoding(channel='y', idx='e1')
        assert e.to_asp() == 'encoding(e1).\nchannel(e1,y).\n'

    def test_only_idx_to_asp(self):
        e = Encoding(idx='e1')
        assert e.to_asp() == 'encoding(e1).\n'

    def test_id_creation(self):
        Encoding.encoding_cnt = 0

        e = Encoding()
        assert e.id == 'e0'

        e = Encoding()
        assert e.id == 'e1'

class TestQuery():

    def test_auto_bin(self):
        q = Query.from_vegalite({
            'mark': 'bar',
            'encoding': {
                'x': {
                    'type': 'nominal'
                },
                "y": {
                    'type': 'quantitative',
                    'aggregate': 'sum'
                },
                'color': {
                    'type': 'nominal'
                }
            }
        })

        encs = [e for e in q.encodings if e.stack]

        assert len(encs) == 1
        assert encs[0].stack == 'zero'

    def test_no_auto_bin(self):
        q = Query.from_vegalite({
            'mark': 'bar',
            'encoding': {
                'x': {
                    'type': 'nominal'
                },
                "y": {
                    'type': 'quantitative',
                    'aggregate': 'mean'
                },
                'color': {
                    'type': 'nominal'
                }
            }
        })

        encs = [e for e in q.encodings if e.stack]

        assert len(encs) == 0
