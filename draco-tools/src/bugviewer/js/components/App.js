import React, { Component } from 'react';
import 'bugviewer/scss/App.css';

import Visualization from 'shared/js/components/Visualization';

const BUGS = require('../../example.json');

class App extends Component {
  render() {
    const bugs = [];
    for (let i = 0; i < BUGS.length; i++) {
      const bug = BUGS[i];
      for (const vlSpec of [bug.left, bug.right]) {
        const dataUrl = vlSpec.data.url;
        const data = require('vega-datasets/' + dataUrl);
        delete vlSpec.data.url;
        vlSpec.data.values = data;
        vlSpec.width = 100;
        vlSpec.height = 100;
      }

      bugs.push(
        <div className="bug" key={i}>
          <Visualization vlSpec={bug.left}/>
          <div className="relationship">
            <div className="comparison">
              <p>predicted:</p>
              <p>actual:</p>
            </div>
            <div className="comparison">
              <p>{bug.prediction}</p>
              <p>{bug.actual}</p>
            </div>
          </div>
          <Visualization vlSpec={bug.right}/>
        </div>
      );
    }

    return (
      <div className="App">
        {bugs}
      </div>
    );
  }
}

export default App;
