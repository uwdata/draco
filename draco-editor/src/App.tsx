import * as React from 'react';
import { HashRouter as Router, Route, Link, Redirect } from 'react-router-dom';
import Draco from 'draco-vis';
import './App.css';
import Navbar from './Navbar';
import Editor from './draco-editor/components/Editor';
import About from './about/components/About';

interface State {
  status: string
};

class App extends React.Component<any, State> {
  draco: Draco;

  constructor(props: any) {
    super(props);

    this.state = {
      status: ""
    }

    this.draco = new Draco("static", (status: string) => {
      console.log(status);
      this.setState({ status });
    });

    this.updateStatus = this.updateStatus.bind(this);
  }

  public render() {
    return (
      <Router basename={BASENAME}>
        <div className="App">
          <div className="content">
            <Route path="/" component={Navbar} />
            <Route exact path="/" render={() => <Redirect to="/editor" />} />
            <Route exact path="/editor" render={() => {
              return <Editor draco={this.draco} status={this.state.status}
                updateStatus={this.updateStatus} />
            }} />
            <Route exact path="/about" component={About} />
          </div>
        </div>
      </Router>
    );
  }

  private updateStatus(status: string) {
    this.setState({ status });
  }
}

export default App;
