import math
import json
from typing import Dict

class Spec(dict):
    def __init__(self, *args, **kw):
        super(Spec, self).__init__(*args, **kw)
        self['encoding'] = {}

    def __hash__(self):
        return json.dumps(self, sort_keys=True).__hash__()

    def get_enc_by_channel(self, channel) -> Dict:
        """
        Returns the encoding associated with the given channel,
        None if it does not exist.
        """
        if (channel in self['encoding']):
            return self['encoding'][channel]
        else:
            return None
