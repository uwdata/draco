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

const EXAMPLE = `% ====== Data definitions ======
num_rows(142).

fieldtype(horsepower,number).
cardinality(horsepower,94).

fieldtype(acceleration,number).
cardinality(acceleration,96).

% ====== Query constraints ======
encoding(e0).
:- not field(e0,acceleration).

encoding(e1).
:- not field(e1,horsepower).
`;

export default class Editor extends React.Component<any, State> {
  draco: Draco;

  public constructor(props: any) {
    super(props);
    this.state = {
      code: EXAMPLE,
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
        <SplitPane split="vertical" defaultSize="30%" minSize={400}>
          <div className="input-pane">
            <div className="toolbar">
              <button className="button left">options</button>
              <button className="button right">run</button>
            </div>
            <MonacoEditor
              options={{
                automaticLayout: true,
                cursorBlinking: "smooth",
                wordWrap: "on",
                wrappingIndent: "same",
                minimap: {
                  enabled: false
                }
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
