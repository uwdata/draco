#script (python)

import sys
import json
from collections import defaultdict

counts = defaultdict(int)

def main(prg):
    prg.ground([('base', [])])

    model = None
    for m in prg.solve(yield_=True):
        model = m

    if model:
        for atom in model.symbols(atoms=True):
            if atom.name == 'feature_term':
                name = atom.arguments[0].string
                counts[name] += 1
        print >> sys.stderr, json.dumps(counts)

#end.
