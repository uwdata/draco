const HOLE = '?';

export default function cql2asp(spec: any) {
  for (let i = 0; i < spec.encodings.length; i++) {
    const enc = spec.encodings[i];
    const eid = `e${i}`;

    const scale = subst_if_hole(spec.scale);
    let binning = subst_if_hole(spec.bin);
    if (typeof binning === 'object') {
      binning = binning.maxbins;
    }
  }
}

function subst_if_hole(v: any) {
  return v != HOLE ? v : null;
}

function remove_if_star(v: any) {
  return v != '*' ? v : null;
}
