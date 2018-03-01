import React, { Component } from 'react';
import { BrowserRouter as Router, Route } from 'react-router-dom';

import 'index/scss/App.css';

import ToolTile from './ToolTile';
import SpecViewer from 'specviewer/js/components/SpecViewer';
import Labeler from 'labeler/js/components/Labeler';
import DatasetViewer from 'datasetviewer/js/components/DatasetViewer';

const TOOLS = [
  {
    name: 'Spec Viewer',
    description: 'View many specs side by side',
    route: '/specviewer',
  },
  {
    name: 'Labeler',
    description: 'Label pairs of visualizations',
    route: '/labeler',
  },
  {
    name: 'Dataset Viewer',
    description: 'View specs generated for labeling (to be pooled)',
    route: '/datasetviewer'
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
    };

    return (
      <Router>
        <div>
          <Route exact path="/" component={Home} />
          <Route path="/specviewer" component={SpecViewer} />
          <Route path="/labeler" component={Labeler} />
          <Route path="/datasetviewer" component={DatasetViewer} />
        </div>
      </Router>
    );
  }
}

export default App;
