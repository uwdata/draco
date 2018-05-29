import * as React from 'react';
import ReactJson from 'react-json-view';
import { TopLevelSpec } from 'vega-lite';
import VegaLiteChart from '../../shared/components/VegaLiteChart';

import '../styles/Recommendations.css';

interface Props {
  results: any
}

interface State {

}

export default class Recommendations extends React.Component<Props, State> {
  render() {
    if (!this.props.results) {
      return null;
    }

    const vlSpec = this.props.results.specs[0] as TopLevelSpec;
    return (
      <div className="Recommendations">
        <div className="visualizations">
          <VegaLiteChart vlSpec={vlSpec} renderer="svg"/>
        </div>
        <div className="raw">
          <ReactJson src={this.props.results}
            theme="rjv-default"
            enableClipboard={false}
            collapsed={false}
            indentWidth={2}/>
        </div>
      </div>
    );
  }
}
