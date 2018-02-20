const vl = require('vega-lite/build/src');
const vega = require('vega');

/**
 * Outputs a png image for the given vega-lite
 * specification to the given outfile.
 *
 * @param {Spec} vlSpec The vega-lite spec to
 *        translate.
 */
export async function vl2svg(vlSpec, callback) {
  const spec =  vl.compile(vlSpec).spec;

  const view = new vega.View(vega.parse(spec), {
    loader: vega.loader({baseURL: null}),
    logLevel: vega.Warn,
    renderer: 'none'
  }).initialize()
    .toSVG();

    return view;
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