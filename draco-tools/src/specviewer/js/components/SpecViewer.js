import 'specviewer/scss/SpecViewer.css';

import * as stringify from 'json-stable-stringify';
import React, { Component } from 'react';
import Visualization from 'shared/js/components/Visualization';

class SpecViewer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      data: undefined,
      specs: (new URL(window.location.href)).searchParams.get('data') || '/spec_pairs/data.json'
    };
  }

  componentDidMount() {
    fetch(this.state.specs)
      .then(response => response.json())
      .then(data => this.setState({ data: data }));
  }

  render() {
    const data = this.state.data;

    if (!data) {
      return <div>loading...</div>;
    }

    const headers = data.headers;

    const pairs = [];
    for (let i = 0; i < data.specs.length; i++) {
      const pair = data.specs[i];

      const properties = Object.keys(pair.properties || {}).map((p, i) => <p key={i}><strong>{p}: </strong>{stringify(pair.properties[p])}</p>);

      pairs.push(
        <div className="spec" key={i}>
          <div className="visualizations">
            <Visualization vlSpec={pair.first}/>
            <Visualization vlSpec={pair.second}/>
          </div>
          {properties}
        </div>
      );
    }

    return (
      <div className="SpecViewer">
        <p>
          You are viewing <code>{this.state.specs}</code>. Append <code>?data=spec_pairs/FILE.json</code> to the URL to change the source.
        </p>
        <div className="main">
          <div className="label">
            {headers.first.title}<br/><small>{headers.first.subtitle}</small>
          </div>
          <div className="label">
            {headers.second.title}<br/><small>{headers.second.subtitle}</small>
          </div>
          {pairs}
        </div>
      </div>
    );
  }
}

export default SpecViewer;
