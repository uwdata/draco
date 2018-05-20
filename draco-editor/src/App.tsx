import * as React from 'react';
import './App.css';
import Editor from './draco-editor/components/Editor';
import Navbar from './Navbar';



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