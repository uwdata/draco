import React, { Component } from 'react';
import { BrowserRouter as Router, Route } from "react-router-dom";

import 'index/scss/App.css';

import ToolTile from './ToolTile';
import BugViewer from 'bugviewer/js/components/BugViewer';
import Labeler from 'labeler/js/components/Labeler';

const TOOLS = [
  {
    name: 'Bug Viewer',
    description: 'View bugs (incorrect predictions)',
    route: '/bugviewer',
  },
  {
    name: 'Labeler',
    description: 'Label pairs of visualizations',
    route: '/labeler',
  }
];

class App extends Component {
  render() {
    const Home = () => {
      const tools = [];

      for (const tool of TOOLS) {
        tools.push(
          <ToolTile key={tool.name} name={tool.name} description={tool.description} route={tool.route} />
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

    return (
      <Router>
        <div>
          <Route exact path="/" component={Home} />
          <Route path="/bugviewer" component={BugViewer} />
          <Route path="/labeler" component={Labeler} />
        </div>
      </Router>
    );
  }
}

export default App;
