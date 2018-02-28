import React, { Component } from 'react';
import 'specviewer/scss/SpecViewer.css';

import Visualization from 'shared/js/components/Visualization';

class SpecViewer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      data: undefined,
    };
  }

  componentDidMount() {
    fetch((new URL(window.location.href)).searchParams.get("data") || 'bugs.json')
      .then(response => response.json())
      .then(data => this.setState({ data: data }));
  }

  render() {
    const data = this.state.data;

    if (!data) {
      return <div>loading...</div>
    }

    const headers = data.headers;

    const pairs = [];
    for (let i = 0; i < data.specs.length; i++) {
      const pair = data.specs[i];

      const properties = Object.keys(pair.properties || {}).map((p, i) => <p key={i}><strong>{p}: </strong>{pair.properties[p]}</p>)

      pairs.push(
        <div className="spec" key={i}>
          <div className="visualizations">
            <Visualization vlSpec={pair.negative}/>
            <Visualization vlSpec={pair.positive}/>
          </div>
          {properties}
        </div>
      );
    }

    return (
      <div className="SpecViewer">
        <div className="label">
          {headers.first.title}<br/><small>{headers.first.subtitle}</small>
        </div>
        <div className="label">
          {headers.second.title}<br/><small>{headers.second.subtitle}</small>
        </div>
        {pairs}
      </div>
    );
  }
}

export default SpecViewer;
