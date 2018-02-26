const vl = require('vega-lite/build/src');
const vega = require('vega');

/**
 * Outputs a png image for the given vega-lite
 * specification to the given outfile.
 *
 * @param {Spec} vlSpec The vega-lite spec to
 *        translate.
 */
export function vl2view(vlSpec, parent) {
  const spec =  vl.compile(vlSpec).spec;

  new vega.View(vega.parse(spec))
    .renderer('svg')
    .initialize(parent)
    .run();
}

/**
 * Returns true iff a and be are equal (deep equality).
 *
 * @param {Object} a
 * @param {Object} b
 */
export function equals(a, b) {
  return JSON.stringify(a) === JSON.stringify(b);
}
