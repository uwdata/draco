import * as React from 'react';
import MonacoEditor from 'react-monaco-editor';
import SplitPane from 'react-split-pane';

import '../styles/Editor.css';
import '../styles/Resizer.css';

interface State {
  code: string
};

class Editor extends React.Component<any, State> {
  public constructor(props: any) {
    super(props);
    this.state = {
      code: '// enter your query here'
    }

    this.editorDidMount = this.editorDidMount.bind(this);
  }

  public editorDidMount(editor: any) {
    editor.focus();
  }

  public render() {
    return (
      <div className="Editor">
        <SplitPane split="vertical" defaultSize="40%" minSize={400}>
            <MonacoEditor
              language="prolog"
              value={this.state.code}
              editorDidMount={this.editorDidMount}/>
            <div>cool</div>
        </SplitPane>
      </div>
    );
  }
}

export default Editor;
