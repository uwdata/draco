import * as React from 'react';
import MonacoEditor from 'react-monaco-editor';
import SplitPane from 'react-split-pane';

import '../../Resizer.css';
import '../styles/Editor.css';

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
    const requireConfig = {
      paths: {
        'vs': 'https://cdn.jsdelivr.net/npm/monaco@latest/build/vs/'
      },
      url: 'https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.1/require.min.js',
    };

    return (
      <div className="Editor">
        <SplitPane split="vertical" defaultSize="40%" minSize={400}>
            <MonacoEditor editorDidMount={this.editorDidMount} requireConfig={requireConfig}/>
            <div/>
        </SplitPane>
      </div>
    );
  }
}

export default Editor;
