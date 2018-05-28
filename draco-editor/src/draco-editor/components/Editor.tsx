import Draco from "draco-vis";
import * as React from "react";
import MonacoEditor from "react-monaco-editor";
import SplitPane from "react-split-pane";
import Status from "./status";
import "../styles/Editor.css";
import "../styles/Resizer.css";

interface State {
  code: string;
  status: string;
}

export default class Editor extends React.Component<any, State> {
  draco: Draco;

  public constructor(props: any) {
    super(props);
    this.state = {
      code: "",
      status: ""
    };

    this.draco = new Draco("dist", status => {
      this.setState({ status });
    });

    this.editorDidMount = this.editorDidMount.bind(this);
    this.handleEditorChange = this.handleEditorChange.bind(this);
  }

  public componentDidMount() {
    this.draco.init();
  }

  public editorDidMount(editor: any) {
    editor.focus();
  }

  public render() {
    return (
      <div className="Editor">
        <SplitPane split="vertical" defaultSize="40%" minSize={400}>
          <div className="input-pane">
            <MonacoEditor
              options={{
                automaticLayout: true,
                cursorBlinking: "smooth",
                wordWrap: "on",
                wrappingIndent: "same"
              }}
              language={null}
              value={this.state.code}
              editorDidMount={this.editorDidMount}
              onChange={this.handleEditorChange}
            />
            <Status status={this.state.status} />
          </div>
          <div className="recommendations">Output</div>
        </SplitPane>
      </div>
    );
  }

  private handleEditorChange(newValue: string, e: any) {
    console.log(newValue);
  }
}
