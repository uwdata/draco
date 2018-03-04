import React, { Component } from 'react';
import 'datasetviewer/scss/DatasetChooser.css';

const classnames = require('classnames');

class DatasetChooser extends Component {
  constructor(props) {
    super(props);
    this.state = {
      dropdown: false
    };
  }

  render() {
    const datasetOptions = [];
    for (const dataset of this.props.datasets) {
      if (dataset.includes(this.state.inputText) || !this.state.inputText) {
        datasetOptions.push(
          <li className="dropdown-item" key={dataset} onMouseDown={(e) => {
            this.props.setDataset(e.target.textContent);
          }}>{dataset}</li>
        );
      }
    }

    const dropdown = (
      <ol className="dropdown-content">
        {datasetOptions}
      </ol>
    );


    const dimensions = [];
    if (this.props.availableDimensions) {
      for (let i = 0; i < this.props.availableDimensions.length; i++) {
        const d = this.props.availableDimensions[i];

        const dimClasses = classnames({
          'dim-option': true,
          'selected': d === this.props.selectedDimension
        });

        dimensions.push(
          <div className={dimClasses} key={i} onClick={() => this.props.setDimension(d) }>{d}</div>
        );
      }
    }

    return (
      <div className="DatasetChooser">
          <div className="search-title">
              {this.props.dataset}
          </div>
          <div className="search-bar">
              <input className="search-input" type="text" placeholder="choose an interaction"
                     onChange={(e) => { this.setInputText(e); }}></input>
              {dropdown}
          </div>
          <div className="dimensions">
            <span style={{paddingLeft: '8px', paddingRight: '8px'}}>dimensions:</span>
            {dimensions}
          </div>
      </div>
    );
  }

  setInputText(e) {
    this.setState({
      inputText: e.target.value
    });
  }
}

export default DatasetChooser;
