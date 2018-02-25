import React, { Component } from 'react';
import 'bugviewer/scss/BugViewer.css';

import Visualization from 'shared/js/components/Visualization';

const BUGS = require('bugviewer/bugs.json');

class BugViewer extends Component {
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
      <div className="BugViewer">
        {bugs}
      </div>
    );
  }
}

export default BugViewer;
