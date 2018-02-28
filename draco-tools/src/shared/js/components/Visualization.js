import React, { Component } from 'react';
import { vl2view, equals } from 'shared/js/utilities/util';

import 'shared/scss/Visualization.css';

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
    vl2view(vlSpec, this.refs.vis);
  }
}

export default Visualization;
