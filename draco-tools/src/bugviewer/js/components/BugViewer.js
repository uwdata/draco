import React, { Component } from 'react';
import 'bugviewer/scss/BugViewer.css';

import Visualization from 'shared/js/components/Visualization';

const BUGS = require('bugviewer/bugs.json');

class BugViewer extends Component {
  render() {
    const bugs = [];
    for (let i = 0; i < BUGS.length; i++) {
      const bug = BUGS[i];

      bugs.push(
        <div className="bug" key={i}>
          <div className="visualizations">
            <div>
              <span className="label">
                Negative<br/><small>but was predicted as better</small>
              </span>
              <Visualization vlSpec={bug.negative}/>
            </div>
            <div>
              <span className="label">
                Positive<br/><small>but was predicted as worse</small>
              </span>
              <Visualization vlSpec={bug.positive}/>
            </div>
          </div>
          <p>
            Confidence: {bug.confidence}
          </p>
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
