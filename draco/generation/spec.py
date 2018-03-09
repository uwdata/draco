import math
import json
from typing import Dict
from sortedcontainers import SortedDict

class Spec(SortedDict):
    def __init__(self, *args, **kw):
        super(Spec, self).__init__(*args, **kw)
        self['encoding'] = SortedDict()

    def __hash__(self):
        return json.dumps(self).__hash__()

    def get_enc_by_channel(self, channel) -> Dict:
        """
        Returns the encoding associated with the given channel,
        None if it does not exist.
        """
        if (channel in self['encoding']):
            return self['encoding'][channel]
        else:
            return None
