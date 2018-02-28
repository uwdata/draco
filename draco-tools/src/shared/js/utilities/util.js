import * as vl from 'vega-lite';
import * as vega from 'vega';

const datasets = {
  'data/cars.json': require('vega-datasets/data/cars.json')
};

/**
 * Outputs a png image for the given vega-lite
 * specification to the given outfile.
 *
 * @param {Spec} vlSpec The vega-lite spec to
 *        translate.
 */
export function vl2view(vlSpec, parent) {
  const spec =  vl.compile(vlSpec).spec;

  const loader = vega.loader();

  const original_http = loader.http;
  loader.http = (url, options) => {
    console.debug(url);

    if (url in datasets) {
      return datasets[url];
    }
    return original_http(url, options);
  };

  new vega.View(vega.parse(spec), {loader})
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
