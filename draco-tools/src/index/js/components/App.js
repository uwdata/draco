import React, { Component } from 'react';
import 'index/scss/App.css';

import ToolTile from './ToolTile';

const TOOLS = [
  {
    name: 'Bug Viewer', 
    description: 'View bugs (incorrect predictions)',
    url: 'bugviewer.html',
  }
];

class App extends Component {
  render() {
    const tools = [];

    for (const tool of TOOLS) {
      tools.push(
        <ToolTile key={tool.name} name={tool.name} description={tool.description} url={tool.url} />
      );
    }

    return (
      <div className="App">
        <div className="title">
          Tools for Draco
        </div>
        <div className="tools">
          {tools}
        </div>
      </div>
    );
  }
}

export default App;
