import * as React from 'react';

import './App.css';
import Navbar from './Navbar';
import Editor from './draco-editor/components/Editor';

class App extends React.Component {
  public render() {
    return (
      <div className="App">
        <Navbar currTab="editor"/>
        <div className="content">
          <Editor/>
        </div>
      </div>
    );
  }
}

export default App;
