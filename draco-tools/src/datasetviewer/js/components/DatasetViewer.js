import React, { Component } from 'react';
import 'datasetviewer/scss/DatasetViewer.css';

import Visualization from 'shared/js/components/Visualization';
import DatasetChooser from 'datasetviewer/js/components/DatasetChooser';

const BASE_DIR = '/generated_visualizations/';
const SPEC_DIR = BASE_DIR + 'specs/';
const INTERACTIONS = BASE_DIR + 'interactions.json';
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

    this.fetchDataset(DEFAULT_DATASET);
  }

  render() {
    if (!this.state.datasets) {
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

          const specNoData = {};
          Object.assign(specNoData, spec);
          delete specNoData['data'];


          visualizations.push(
            <div className="visualization" key={j}>
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

        if (group.length > 0) {
          pairs += factorial(group.length) / (2 * factorial(group.length - 2));
        }
      }

      info = <div className="summary">{count} visualizations and {pairs} pairs</div>;
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

  setCurrentDimension(d) {
    this.setState({
      currentDimension: d
    });
  }
}

function factorial(n) {
  if (n === 0) {
    return 1;
  }

  let result = 1;
  for (let i = 2; i <= n; i++) {
    result *= i;
  }

  return result;
}

export default DatasetViewer;
