import * as React from 'react';
import { BrowserRouter as Router, Route, Link } from 'react-router-dom';

import './App.css';
import Navbar from './Navbar';
import Editor from './draco-editor/components/Editor';
import About from './about/components/About';

class App extends React.Component {

  public render() {
    return (
      <Router>
        <div className="App">
          <Navbar/>
          <div className="content">
            <Route exact path="/" component={Editor} />
            <Route path="/about" component={About} />
          </div>
        </div>
      </Router>
    );
  }
}

export default App;
