import * as React from 'react';
import { HashRouter as Router, Route, Link, Redirect } from 'react-router-dom';

import './App.css';
import Navbar from './Navbar';
import Editor from './draco-editor/components/Editor';
import About from './about/components/About';

class App extends React.Component {

  public render() {
    return (
      <Router basename={BASENAME}>
        <div className="App">
          <div className="content">
            <Route path="/" component={Navbar} />
            <Route exact path="/" render={() => <Redirect to="/editor" />} />
            <Route exact path="/editor" component={Editor} />
            <Route exact path="/about" component={About} />
          </div>
        </div>
      </Router>
    );
  }
}

export default App;
