import Draco from "draco-vis";
import * as React from "react";
import MonacoEditor from "react-monaco-editor";
import SplitPane from "react-split-pane";
import { ASP_FORMAT, ASP_THEME}  from '../asp';
import "../styles/Editor.css";
import "../styles/Resizer.css";
import Status from "./status";
import * as classNames from 'classnames';

import playIcon from '../../images/play.svg';
import playIconGrey from '../../images/play-grey.svg';
import optionsIcon from '../../images/options.svg';

interface State {
  output: Object;
}

interface Props {
  draco: Draco;
  status: string;
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

export default class Editor extends React.Component<Props, State> {
  code: string;

  public constructor(props: Props) {
    super(props);
    this.state = {
      output: null
    };

    this.code = EXAMPLE;

    this.editorDidMount = this.editorDidMount.bind(this);
    this.handleEditorChange = this.handleEditorChange.bind(this);
    this.run = this.run.bind(this);
  }

  public componentDidMount() {
    if (!this.props.draco.initialized) {
      this.props.draco.init();
    }
  }

  public editorDidMount(editor: any) {
    editor.focus();
  }

  public editorWillMount(monaco: any) {
    monaco.languages.register({ id: "asp" });
    monaco.languages.setMonarchTokensProvider("asp", ASP_FORMAT);
    monaco.editor.defineTheme("draco-light", ASP_THEME);
  }

  public render() {
    return (
      <div className="Editor">
        <div className="split-pane-wrapper">
          <SplitPane split="vertical" defaultSize="30%" minSize={400}>
            <div className="input-pane">
              <div className="toolbar">
                <button className="button left">
                  <img src={optionsIcon} className="icon"/>
                  options
                </button>
                <button className={classNames({
                  'button': true, 'right': true, 'disabled': !this.props.draco.initialized
                })} onClick={this.run} disabled={!this.props.draco.initialized}>
                  <img src={!this.props.draco.initialized ? playIconGrey : playIcon}
                    className="icon"/>
                  run
                </button>
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
                theme="draco-light"
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
        <Status status={this.props.status} />
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
    const result = this.props.draco.solve(program);
    this.setState({
      output: result,
    });
  }
}
