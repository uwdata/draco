import React, { Component } from 'react';
import 'bugviewer/scss/App.css';

import Visualization from 'shared/js/components/Visualization';

const BUGS = require('../../bugs.json');

class App extends Component {
  render() {
    const bugs = [];
    for (let i = 0; i < BUGS.length; i++) {
      const bug = BUGS[i];

      for (const vlSpec of [bug.negative, bug.positive]) {
        vlSpec.width = 100;
        vlSpec.height = 100;
      }

      bugs.push(
        <div className="bug" key={i}>
          <Visualization vlSpec={bug.negative}/>
          <Visualization vlSpec={bug.positive}/>
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
