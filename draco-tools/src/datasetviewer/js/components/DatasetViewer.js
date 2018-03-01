import React, { Component } from 'react';
import 'datasetviewer/scss/DatasetViewer.css';

import Visualization from 'shared/js/components/Visualization';
import DatasetChooser from 'datasetviewer/js/components/DatasetChooser';

const BASE_DIR = '/generated_visualizations/';
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
      specs: undefined
    };
  }

  componentDidMount() {
    fetch(INTERACTIONS)
      .then(response => response.json())
      .then(data => this.setState({ 'datasets': data }));

    fetch(BASE_DIR + DEFAULT_DATASET)
      .then(response => response.json())
      .then(data => this.setState({ specs: data }));

    fetch(DATA)
      .then(response => response.json())
      .then(data => this.setState({ data: data }));
  }

  render() {
    if (!this.state.data || !this.state.datasets) {
      return <div>loading...</div>;
    }

    let vizGroups;
    if (!this.state.specs) {
      vizGroups = <div>loading...</div>;
    } else {
      const groups = this.state.specs.groups;

      vizGroups = [];
      for (let i = 0; i < groups.length; i++) {
        const group = groups[i];
  
        const visualizations = [];
        for (let j = 0; j < group.length; j++) {
          const spec = group[j];
          spec['data'] = { values: this.state.data };
  
          visualizations.push(
            <div className="visualization" key={j}>
              <Visualization vlSpec={spec}/>
            </div>
          );
        }
  
        vizGroups.push(
          <div className="group" key={i}>
            {visualizations}
          </div>
        );
      }
    }

    return (
      <div className="DatasetViewer">
        <DatasetChooser dataset={this.state.dataset} datasets={this.state.datasets}
                        setDataset={this.setDataset.bind(this)}/>
        {vizGroups}
      </div>
    );
  }

  setDataset(name) {
    this.setState({
      dataset: name,
      specs: undefined
    });

    fetch(BASE_DIR + name)
      .then(response => response.json())
      .then(data => this.setState({ dataset: name, specs: data }));
  }
}

export default DatasetViewer;
