import React, { Component } from 'react';
import { equals } from 'shared/js/utilities/util';
import vegaEmbed, { vega } from 'vega-embed';

import 'shared/scss/Visualization.css';

export const datasets = {
  'data/cars.json': require('../../data/cars.json'),
  'data/cars_mod.json': require('../../data/cars_mod.json'),
  'data/movies.json': require('../../data/movies.json'),
  'data/weather.json': require('../../data/weather.json')
};

/**
 * A Visualization component accepts a `vlSpec` as a prop
 * and renders the resulting svg.
 */
class Visualization extends Component {
  componentDidMount() {
    this.updateView(this.props.vlSpec);
  }

  componentWillReceiveProps(nextProps) {
    if (!equals(this.props, nextProps)) {
      this.updateView(nextProps.vlSpec);
    }
  }

  render() {
    return (
      <div className='Visualization' ref='vis'>
      </div>
    );
  }

  /**
   * Updates this to use the given vlSpec.
   *
   * @param {Object} vlSpec The Vega-Lite spec to use.
   */
  updateView(vlSpec) {
    if (!vlSpec) {
      console.warn('no spec passed to viz view');
      return;
    }

    const loader = vega.loader();

    const original_http = loader.http;
    loader.http = (url, options) => {
      console.debug(url);

      if (url in datasets) {
        return datasets[url];
      }
      return original_http(url, options);
    };

    vegaEmbed(this.refs.vis, vlSpec, { renderer: this.props.renderer, loader: loader, mode: 'vega-lite', actions: { editor: false, export: false } });
  }
}

export default Visualization;
