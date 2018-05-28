import Draco from "draco-vis";
import * as React from "react";
import MonacoEditor from "react-monaco-editor";
import SplitPane from "react-split-pane";
import ASP_FORMAT from '../asp';
import "../styles/Editor.css";
import "../styles/Resizer.css";
import Status from "./status";

interface State {
  status: string;
  output: Object;
}

interface Monaco {
  editor: Object;
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
  code: string;

  public constructor(props: any) {
    super(props);
    this.state = {
      status: "",
      output: null
    };

    this.code = EXAMPLE;
    this.draco = new Draco("dist", status => {
      console.log(status);
      this.setState({ status });
    });

    this.editorDidMount = this.editorDidMount.bind(this);
    this.handleEditorChange = this.handleEditorChange.bind(this);
    this.run = this.run.bind(this);
  }

  public componentDidMount() {
    this.draco.init();
  }

  public editorDidMount(editor: any) {
    editor.focus();
  }

  public editorWillMount(monaco: any) {
    monaco.languages.register({ id: "asp" });
    monaco.languages.setMonarchTokensProvider("asp", ASP_FORMAT);
  }

  public render() {
    return (
      <div className="Editor">
        <div className="split-pane-wrapper">
          <SplitPane split="vertical" defaultSize="30%" minSize={400}>
            <div className="input-pane">
              <div className="toolbar">
                <button className="button left">options</button>
                <button className="button right" onClick={this.run} disabled={!this.draco.initialized}>run</button>
              </div>
              <MonacoEditor
                ref="monaco"
                options={{
                  automaticLayout: true,
                  cursorBlinking: "smooth",
                  wordWrap: "on",
                  wrappingIndent: "same",
                  scrollBeyondLastLine: false,
                  minimap: {
                    enabled: false
                  }
                }}
                language="asp"
                value={this.code}
                editorDidMount={this.editorDidMount}
                editorWillMount={this.editorWillMount}
                onChange={this.handleEditorChange}
              />
            </div>
            <div className="recommendations">
              <pre>{JSON.stringify(this.state.output, null, 2)}</pre>
            </div>
          </SplitPane>
        </div>
        <Status status={this.state.status} />
      </div>
    );
  }

  private handleEditorChange(newValue: string, e: any) {
    this.code = newValue;
  }

  private run() {
    const monaco = this.refs.monaco as any;
    const model = monaco.editor.getModel();
    const program = model.getValue();
    const result = this.draco.solve(program);
    this.setState({
      output: result,
      status: ""
    })
  }
}
