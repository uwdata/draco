import React, { Component } from 'react';
import 'bugviewer/scss/BugViewer.css';

import Visualization from 'shared/js/components/Visualization';

class BugViewer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      bugs: undefined,
    };
  }

  componentDidMount() {
    fetch((new URL(window.location.href)).searchParams.get("data") || 'bugs.json')
      .then(response => response.json())
      .then(data => this.setState({ bugs: data }));
  }

  render() {
    const BUGS = this.state.bugs;

    if (!BUGS) {
      return <div>loading...</div>
    }

    const headers = BUGS.headers;

    const bugs = [];
    for (let i = 0; i < 5; i++) {
      const bug = BUGS.specs[i];

      const properties = Object.keys(bug.properties || {}).map((p, i) => <p key={i}><strong>{p}: </strong>{bug.properties[p]}</p>)

      bugs.push(
        <div className="bug" key={i}>
          <div className="visualizations">
            <Visualization vlSpec={bug.negative}/>
            <Visualization vlSpec={bug.positive}/>
          </div>
          {properties}
        </div>
      );
    }

    return (
      <div className="BugViewer">
        <div className="header">
          <div className="label">
            {headers.first.title}<br/><small>{headers.first.subtitle}</small>
          </div>
          <div className="label">
            {headers.second.title}<br/><small>{headers.second.subtitle}</small>
          </div>
        </div>
        {bugs}
      </div>
    );
  }
}

export default BugViewer;
