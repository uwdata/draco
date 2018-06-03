import * as React from 'react';
import ReactJson from 'react-json-view';
import { TopLevelSpec } from 'vega-lite';
import SplitPane from 'react-split-pane';
import VegaLiteChart from '../../shared/components/VegaLiteChart';
import * as classNames from 'classnames';
import AnimateOnChange from 'react-animate-on-change';

import '../styles/Recommendations.css';
import expandButton from '../../images/expand.svg';

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
  showInfoPane: boolean;
}

const COLLAPSED_INFO_PANE_SIZE = 24;
const DEFAULT_INFO_PANE_SIZE = 344;

export default class Recommendations extends React.Component<Props, State> {
  previousInfoPaneSize: number;  // -1 for none

  constructor(props: Props) {
    super(props);

    this.state = {
      focusIndex: props.focusIndex,
      runId: -1,
      updateFocus: true,
      showInfoPane: false,
    }

    this.previousInfoPaneSize = -1;
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
          <VegaLiteChart vlSpec={spec} renderer="canvas" actions={false} />
          <div className="backdrop"></div>
          <div className="cost">
            {`${index === 0 ? 'cost: ' : ''}${this.props.results.models[index].costs[0]}`}
          </div>
        </div>
      );
    });

    const model = this.props.results.models[this.props.focusIndex];

    const info = {
      spec: focusSpec,
      cost: model.costs[0],
      violations: model.facts.filter((d: string) => d.startsWith('violation')),
    };

    return (
      <div className="Recommendations">
        <SplitPane split="vertical" primary="second"
          size={
            this.state.showInfoPane ?
              this.previousInfoPaneSize === -1 ? DEFAULT_INFO_PANE_SIZE : this.previousInfoPaneSize
            :
              COLLAPSED_INFO_PANE_SIZE
          }
          allowResize={this.state.showInfoPane}
          onDragFinished={(size: number) => { this.previousInfoPaneSize = size}}
          minSize={24} maxSize={-400}>
          <div className="visualizations">
            <div className="tabs">
              <button className={classNames({
                'tab': true,
                'selected': this.props.view === 'focus'
              })} onClick={() =>  { this.props.setView('focus'); }}>
                <span className="text">single</span>
              </button>
              <button className={classNames({
                'tab': true,
                'selected': this.props.view === 'grid'
              })} onClick={() =>  { this.props.setView('grid'); }}>
                <div className="text">grid</div>
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
            <button className="expand-button" onClick={() => { this.setState({ showInfoPane: !this.state.showInfoPane }); }}>
              <img className={classNames({
                'expand-icon': true,
                'collapse': this.state.showInfoPane
               })} src={expandButton}/>
            </button>
            <div className="raw-container">
              <div className="raw">
                <ReactJson src={info}
                  theme="rjv-default"
                  enableClipboard={false}
                  collapsed={false}
                  indentWidth={2} />
              </div>
            </div>
          </div>
        </SplitPane>
      </div>
    );
  }
}
