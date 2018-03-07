import math
import json

class Spec(dict):
    def __init__(self, *args, **kw):
        super(Spec, self).__init__(*args, **kw)
        self['encoding'] = {}

    def __hash__(self):
        return json.dumps(self, sort_keys=True).__hash__()
