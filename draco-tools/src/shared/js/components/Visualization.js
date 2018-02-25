import React, { Component } from 'react';
import { vl2svg, equals } from 'shared/js/utilities/util';

import 'shared/scss/Visualization.css';

/**
 * A Visualization component accepts a `vlSpec` as a prop
 * and renders the resulting svg.
 */
class Visualization extends Component {
  constructor(props) {
    super(props);
    this.state = {
      svg: null
    };
    this.updateSvg(this.props.vlSpec);
  }

  componentWillReceiveProps(nextProps) {
    if (!equals(this.props, nextProps)) {
      this.updateSvg(nextProps.vlSpec);
    }
  }

  render() {
    return (
      <div className="Visualization">
        <span dangerouslySetInnerHTML={{__html: this.state.svg}} />
      </div>
    );
  }

  /**
   * Updates this to use the given vlSpec.
   * 
   * @param {Object} vlSpec The Vega-Lite spec to use.
   */
  updateSvg(vlSpec) {
    vl2svg(vlSpec).then(
      (svg) => {
        this.setState({
          svg: svg,
        });
      }
    );
  }
}

export default Visualization;