#script (python)

from __future__ import print_function

import sys
import json
from collections import defaultdict

def main(prg):
    prg.ground([('base', [])])

    counts = None

    for model in prg.solve(yield_=True):
        counts = defaultdict(int)

        for atom in model.symbols(atoms=True):
            if atom.name == 'feature_term' and len(atom.arguments) == 2:
                name = atom.arguments[0].string
                counts[name] += 1
    print(json.dumps(counts), file=sys.stderr)

#end.
