import React, { Component } from 'react';
import 'datasetviewer/scss/DatasetViewer.css';

import Visualization from 'shared/js/components/Visualization';
import DatasetChooser from 'datasetviewer/js/components/DatasetChooser';

const BASE_DIR = '/generated_visualizations/';
const SPEC_DIR = BASE_DIR + 'specs/';
const INTERACTIONS = BASE_DIR + 'interactions.json';
const DATA = BASE_DIR + 'cars.json';
const DEFAULT_DATASET = 'mark.json';

class DatasetViewer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      data: undefined,
      dataset: DEFAULT_DATASET,
      datasets: undefined,
      specs: undefined,
      currentDimension: undefined
    };

  }

  componentDidMount() {
    fetch(INTERACTIONS)
      .then(response => response.json())
      .then(data => this.setState({ 'datasets': data }));

    fetch(DATA)
      .then(response => response.json())
      .then(data => this.setState({ data: data }));

    this.fetchDataset(DEFAULT_DATASET);

    document.body.addEventListener('click', this.removeCurrentSpec.bind(this));
  }

  componentWillUnmount() {
    document.body.removeEventListener('click', this.removeCurrentSpec.bind(this));
  }

  render() {
    if (!this.state.data || !this.state.datasets) {
      return <div>loading...</div>;
    }

    let vizGroups;
    let info;
    let specView;
    if (!this.state.specs) {
      vizGroups = <div>loading...</div>;
    } else {
      let pairs = 0;
      let count = 0;


      const groups = this.state.specs[this.state.currentDimension];

      vizGroups = [];
      for (let i = 0; i < groups.length; i++) {
        const group = groups[i];

        const visualizations = [];
        for (let j = 0; j < group.length; j++) {
          const spec = group[j];
          spec['data'] = { values: this.state.data };

          const specNoData = {};
          Object.assign(specNoData, spec);
          delete specNoData['data'];


          visualizations.push(
            <div className="visualization" key={j} onClick={ (e) => this.setCurrentSpec(e, specNoData) }>
              <Visualization vlSpec={spec} renderer="canvas"/>
            </div>
          );
        }

        vizGroups.push(
          <div className="group" key={i}>
            {visualizations}
          </div>
        );

        count += group.length;
        pairs += factorial(group.length) / (2 * factorial(group.length - 2));
      }

      info = <div className="summary">{count} visualizations and {pairs} pairs</div>;

      if (this.state.currentSpec) {
        specView = (
          <div className="spec-view" onClick={(e) => { e.stopPropagation(); }} style={{
            left: this.state.specX - 100 + 'px', top: this.state.specY + 50 + 'px'
          }}>
            <pre>{JSON.stringify(this.state.currentSpec, null, 2)}</pre>
          </div>
        );
      }
    }

    return (
      <div className="DatasetViewer">
        <div className="header">
          <DatasetChooser dataset={this.state.dataset} datasets={this.state.datasets}
                          setDataset={this.setDataset.bind(this)}
                          availableDimensions={this.state.availableDimensions}
                          selectedDimension={this.state.currentDimension}
                          setDimension={this.setCurrentDimension.bind(this)} />
          {info}
        </div>
        {vizGroups}
        {specView}
      </div>
    );
  }

  setDataset(name) {
    this.setState({
      dataset: name,
      specs: undefined
    });

    fetch(SPEC_DIR + name)
      .then(response => response.json())
      .then(data => this.setState({ dataset: name, specs: data }));
  }

  fetchDataset(name) {
    fetch(SPEC_DIR + name)
      .then(response => response.json())
      .then(data => {
        const dimensions = [];
        for (let d in data) {
          dimensions.push(d);
        }
        dimensions.sort();

        this.setState({
          dataset: name,
          specs: data,
          availableDimensions: dimensions,
          currentDimension: dimensions[0] });
      });
  }

  setCurrentSpec(event, spec) {
    this.setState({
      currentSpec: spec,
      specX: event.pageX,
      specY: event.pageY
    });
  }

  removeCurrentSpec(e) {
    this.setState({
      currentSpec: undefined
    });
  }

  setCurrentDimension(d) {
    this.setState({
      currentDimension: d
    });
  }
}

function factorial(n) {
  let result = 1;
  for (let i = 2; i <= n; i++) {
    result *= i;
  }

  return result;
}

export default DatasetViewer;
