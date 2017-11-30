#script (python)

import sys
import json
from collections import namedtuple

VolationAtom = namedtuple('VolationAtom', ['name', 'args'])

collect = {
    'aggregate': VolationAtom('agg_count', 2),
    'encoding': VolationAtom('encoding_count', 1),
    'shape_cardinality_violated': VolationAtom('shape_cardinality_count', 1),
    'number_nominal_violated': VolationAtom('number_nominal_count', 1),
}

counts = {value.name: 0 for value in collect.values()}

def main(prg):
    prg.ground([('base', [])])

    model = None
    for m in prg.solve(yield_=True):
        model = m

    if model:
        for atom in model.symbols(atoms=True):
            if atom.name in collect and len(atom.arguments) == collect[atom.name].args:
                counts[collect[atom.name].name] += 1
        print >> sys.stderr, json.dumps(counts)

#end.
