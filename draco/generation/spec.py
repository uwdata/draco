import math
import json
from collections import OrderedDict

class Spec(dict):
    def __init__(self, *args, **kw):
        super(Spec, self).__init__(*args, **kw)
        self['encoding'] = OrderedDict()

    def __hash__(self):
        return json.dumps(self, sort_keys=True).__hash__()

    def get_enc_by_channel(self, channel):
        if (channel in self['encoding']):
            return self['encoding'][channel]
        return None

    def contains_prop(self, prop):
        if (prop in self):
            return True

        for enc in self['encoding']:
            if (prop in enc):
                return True

        return False
