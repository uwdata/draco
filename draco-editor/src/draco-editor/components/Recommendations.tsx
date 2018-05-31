import * as React from 'react';
import ReactJson from 'react-json-view';
import { TopLevelSpec } from 'vega-lite';
import SplitPane from 'react-split-pane';
import VegaLiteChart from '../../shared/components/VegaLiteChart';
import * as classNames from 'classnames';
import AnimateOnChange from 'react-animate-on-change';

import '../styles/Recommendations.css';

export type VizView = 'focus' | 'grid';

interface Props {
  results: any;
  focusIndex: number;
  setFocusIndex: (focusIndex: number) => void;
  runId: number;  // to identify unique runs
  view: VizView;  // focus for focus + context, grid for grid view.
  setView: (view: VizView) => void;
}

interface State {
  focusIndex: number;
  runId: number;
  updateFocus: boolean;
}

export default class Recommendations extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      focusIndex: props.focusIndex,
      runId: -1,
      updateFocus: true
    }
  }

  static getDerivedStateFromProps(props: Props, state: State) {

    return {
      focusIndex: props.focusIndex,
      runId: props.runId,
      updateFocus: props.focusIndex !== state.focusIndex ||
        props.runId !== state.runId
    }
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
          <div className="backdrop"></div>
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
        <SplitPane split="vertical" primary="second" defaultSize={344} minSize={24} maxSize={-400}>
          <div className="visualizations">
            <div className="tabs">
              <button className={classNames({
                'tab': true,
                'selected': this.props.view === 'focus'
              })} onClick={() =>  { this.props.setView('focus'); }}>
                <span className="text">Focus + Context</span>
                <div className="backdrop"/>
              </button>
              <button className={classNames({
                'tab': true,
                'selected': this.props.view === 'grid'
              })} onClick={() =>  { this.props.setView('grid'); }}>
                <div className="text">Grid View</div>
                <div className="backdrop"/>
              </button>
            </div>
            <div className={classNames({
              'focus': true,
              'hidden': this.props.view !== 'focus'
            })}>
              <AnimateOnChange
                baseClassName="chart"
                animationClassName="update"
                animate={this.state.updateFocus}>
                  <VegaLiteChart vlSpec={focusSpec} renderer="svg" />
              </AnimateOnChange>

            </div>
            <div className={classNames({
              'context': true,
              'full': this.props.view === 'grid'
            })}>
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
