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
  showOptions: boolean;
  focusIndex: number;
  runCount: number;
  view: VizView;
  models: number;
}

interface Props {
  draco: Draco;
  status: string;
  updateStatus: (status: string) => void
}

interface Monaco {
  editor: Object;
}

const DEFAULT_MODELS = 7;

export default class Editor extends React.Component<Props, State> {
  code: string;

  public constructor(props: Props) {
    super(props);
    this.state = {
      output: null,
      showExamples: false,
      showOptions: false,
      focusIndex: 0,
      runCount: 0,
      view: 'focus',
      models: DEFAULT_MODELS,
    };

    this.code = SCATTER;

    this.editorDidMount = this.editorDidMount.bind(this);
    this.handleEditorChange = this.handleEditorChange.bind(this);
    this.showExamples = this.showExamples.bind(this);
    this.showOptions = this.showOptions.bind(this);
    this.hideDropdowns = this.hideDropdowns.bind(this);
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
      <div className="Editor">
        <div className="split-pane-wrapper">
          <SplitPane split="vertical" defaultSize={344} minSize={256} maxSize={-800}>
            <div className="input-pane">
              <div className="toolbar" onClick={this.hideDropdowns}>
                <button className={classNames({
                  'button': true, 'left': true, 'selected': this.state.showExamples
                })} onClick={this.showExamples}>
                  <img src={examplesIcon} className="icon"/>
                  examples
                </button>
                <button className={classNames({
                  'button': true, 'selected': this.state.showOptions
                })} onClick={this.showOptions}>
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
              <div className="editor-box" onClick={this.hideDropdowns}>
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
              <div className={classNames({
                'dropdown': true,
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
                      this.hideDropdowns();
                    }}>
                      <span className="text">
                        {example.name}
                      </span>
                    </div>
                  );
                })}
              </div>
              <div className={classNames({
                'dropdown': true,
                'hidden': !this.state.showOptions
              })}>
                <div className="option">
                  <span className="text">
                    models
                  </span>
                  <input type="number" className="number-input"
                    value={this.state.models} onChange={(e: any) => {
                      const models = e.target.value;
                      if (models >= 0 && models <= 100) {
                        this.setState({ models })
                      }
                    }}/>
                </div>
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
      models: this.state.models
    });
    this.setState({
      output: result,
      focusIndex: 0,
      runCount: this.state.runCount + 1
    });
  }

  private showExamples() {
    this.setState({
      showExamples: true,
      showOptions: false
    });
  }

  private hideDropdowns() {
    if (this.state.showExamples) {
      this.setState({
        showExamples: false,
      });
    }

    if (this.state.showOptions) {
      this.setState({
        showOptions: false
      })
    }
  }

  private showOptions() {
    this.setState({
      showExamples: false,
      showOptions: true,
    });
  }

  private setFocusIndex(focusIndex: number) {
    this.setState({ focusIndex });
  }

  private setView(view: VizView) {
    this.setState({ view });
  }
}
