import Draco from "draco-vis";
import * as React from "react";
import MonacoEditor from "react-monaco-editor";
import SplitPane from "react-split-pane";
import { ASP_FORMAT, ASP_THEME}  from '../asp';
import "../styles/Editor.css";
import "../styles/Resizer.css";
import Status from "./status";
import * as classNames from 'classnames';
import Recommendations, { VizView } from './Recommendations';

import playIcon from '../../images/play.svg';
import playIconGrey from '../../images/play-grey.svg';
import optionsIcon from '../../images/options.svg';
import examplesIcon from '../../images/examples.svg';

import EXAMPLES, { SCATTER } from '../examples';
interface State {
  output: Object;
  showExamples: boolean;
  focusIndex: number;
  runCount: number;
  view: VizView;
}

interface Props {
  draco: Draco;
  status: string;
  updateStatus: (status: string) => void
}

interface Monaco {
  editor: Object;
}

export default class Editor extends React.Component<Props, State> {
  code: string;

  public constructor(props: Props) {
    super(props);
    this.state = {
      output: null,
      showExamples: false,
      focusIndex: 0,
      runCount: 0,
      view: 'focus'
    };

    this.code = SCATTER;

    this.editorDidMount = this.editorDidMount.bind(this);
    this.handleEditorChange = this.handleEditorChange.bind(this);
    this.showExamples = this.showExamples.bind(this);
    this.hideExamples = this.hideExamples.bind(this);
    this.setFocusIndex = this.setFocusIndex.bind(this);
    this.setView = this.setView.bind(this);
    this.run = this.run.bind(this);
  }

  public componentDidMount() {
    if (!this.props.draco.initialized) {
      this.props.draco.init().then(() => {
        this.run();
      });
    } else {
      this.run();
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
      <div className="Editor" onClick={this.hideExamples}>
        <div className="split-pane-wrapper">
          <SplitPane split="vertical" defaultSize={344} minSize={256} maxSize={-800}>
            <div className="input-pane">
              <div className="toolbar">
                <button className="button left" onClick={this.showExamples}>
                  <img src={examplesIcon} className="icon"/>
                  examples
                </button>
                <button className="button">
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
              <div className={classNames({
                'examples': true,
                'hidden': !this.state.showExamples
              })}>
                {EXAMPLES.map((example) => {
                  return (
                    <div key={example.name} className="example" onClick={() => {
                      this.code = example.program;
                      setTimeout(() => {
                        if (this.props.draco.initialized) {
                          this.run();
                        }
                      }, 10);
                    }}>
                      <span className="text">
                        {example.name}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>
            <Recommendations results={this.state.output}
              runId={this.state.runCount}
              focusIndex={this.state.focusIndex}
              setFocusIndex={this.setFocusIndex}
              view={this.state.view}
              setView={this.setView}/>
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
    const result = this.props.draco.solve(program, {
      models: 5
    });
    this.setState({
      output: result,
      focusIndex: 0,
      runCount: this.state.runCount + 1
    });
  }

  private showExamples() {
    this.setState({
      showExamples: true
    });
  }

  private hideExamples() {
    if (this.state.showExamples) {
      this.setState({
        showExamples: false
      });
    }
  }

  private setFocusIndex(focusIndex: number) {
    this.setState({ focusIndex });
  }

  private setView(view: VizView) {
    this.setState({ view });
  }
}
