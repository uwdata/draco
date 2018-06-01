import * as React from 'react';
import vegaEmbed, { vega, EmbedOptions, Result } from 'vega-embed';
import { View } from 'vega-lib';
import { TopLevelSpec } from 'vega-lite';

import '../styles/VegaLiteChart.css';

export const datasets = {
  // @ts-ignore
  'data/cars.json': require('../../data/cars.json')
};

interface Props {
  vlSpec: TopLevelSpec;
  renderer: "canvas" | "svg";
  actions?: boolean;
}

interface State {

}

/**
 * A Visualization component accepts a `vlSpec` as a prop
 * and renders the resulting svg.
 */
export default class VegaLiteChart extends React.Component<Props, State> {
  componentDidMount() {
    this.updateView(this.props.vlSpec);
  }

  componentWillReceiveProps(nextProps: Props) {
    if (nextProps.vlSpec !== this.props.vlSpec) {
      this.updateView(nextProps.vlSpec);
    }
  }

  render() {
    return (
      <div className='VegaLiteChart' ref='vis'>
      </div>
    );
  }

  /**
   * Updates this to use the given vlSpec.
   *
   * @param {Object} vlSpec The Vega-Lite spec to use.
   */
  updateView(vlSpec: TopLevelSpec) {
    if (!vlSpec) {
      console.warn('no spec passed to viz view');
      return;
    }

    const loader = vega.loader();

    const original_http = loader.http;
    loader.http = (url, options) => {
      console.debug(url);

      if (url in datasets) {
        // @ts-ignore
        return datasets[url];
      }
      return original_http(url, options);
    };

    const element = this.refs.vis as HTMLElement;

    const opt: EmbedOptions = {
      renderer: this.props.renderer,
      loader: loader,
      mode: 'vega-lite',
      defaultStyle: true,
      actions: typeof this.props.actions === 'undefined' ? true : this.props.actions
    };

    // @ts-ignore
    vegaEmbed(element, vlSpec, opt);
  }
}
