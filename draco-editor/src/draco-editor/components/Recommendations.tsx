import * as React from 'react';
import ReactJson from 'react-json-view';
import { TopLevelSpec } from 'vega-lite';
import SplitPane from 'react-split-pane';
import VegaLiteChart from '../../shared/components/VegaLiteChart';
import * as classNames from 'classnames';

import '../styles/Recommendations.css';

interface Props {
  results: any,
  focusIndex: number,
  setFocusIndex: (focusIndex: number) => void
}

interface State {
  focusIndex: number;
}

export default class Recommendations extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
  }

  render() {
    if (!this.props.results) {
      return null;
    }

    const focusSpec = this.props.results.specs[this.props.focusIndex] as TopLevelSpec;
    const contextCharts = this.props.results.specs.map((spec: TopLevelSpec, index: number) => {
      const classes = classNames({
        'context-chart': true,
        'selected': index === this.props.focusIndex
      })

      return (
        <div key={index} className={classes} onClick={() => {
          this.props.setFocusIndex(index);
        }}>
          <VegaLiteChart vlSpec={spec} renderer="svg" actions={false} />
        </div>
      );
    });

    const witness = this.props.results.result.Call[0].Witnesses[this.props.focusIndex];

    const info = {
      spec: focusSpec,
      violations: witness
    };

    return (
      <div className="Recommendations">
        <SplitPane split="vertical" primary="second" defaultSize={400} minSize={400} maxSize={-400}>
          <div className="visualizations">
            <div className="focus">
              <div className="chart">
                <VegaLiteChart vlSpec={focusSpec} renderer="svg"/>
              </div>
            </div>
            <div className="context">
              <div className="carousel">
                {contextCharts}
              </div>
            </div>
          </div>
          <div className="info">
            <div className="raw">
              <ReactJson src={info}
                theme="rjv-default"
                enableClipboard={false}
                collapsed={false}
                indentWidth={2} />
            </div>
          </div>
        </SplitPane>

      </div>
    );
  }
}
