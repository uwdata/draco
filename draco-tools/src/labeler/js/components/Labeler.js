import 'labeler/scss/Labeler.css';

import { diffJson } from 'diff';
import * as stringify from 'json-stable-stringify';
import React, { Component } from 'react';
import Visualization, {datasets} from 'shared/js/components/Visualization';
import { duplicate, unique } from 'vega-lite/build/src/util';

const classnames = require('classnames');

const UNK = '?';
const LEFT = '>';
const EQUALS = '=';
const RIGHT = '<';
const TERRIBLE = 'bad';

const KEYS = {
  37: LEFT,  // left arrow
  39: RIGHT,  // right arrow
  38: EQUALS,  // up arrow
  40: TERRIBLE  // down arrow
};

const url = new URL(document.location.href);
const REQUEST_PATH = `${url.protocol}//${url.hostname}:5000/`;

function cleanUpSpec(spec) {
  if (!spec) {
    return spec;
  }

  spec = duplicate(spec);
  delete spec.$schema;
  delete spec.data.format;
  return spec;
}

class Labeler extends Component {
  constructor(props) {
    super(props);
    this.state = {
      id: null,
      left: null,
      right: null,
      task: null,
      chosen: null,
      hover: UNK,
      requesting: false,
      next: [],
      user: (new URL(window.location.href)).searchParams.get('user') || 'anonymous'
    };
  }

  componentDidMount() {
    this.fetchPairIfNecessary();
    document.body.addEventListener('keydown', this.handleKeyDown.bind(this));
  }

  componentWillUnMount() {
    document.body.removeEventListener('keyup', this.handleKeyDown.bind(this));
  }

  render() {
    let leftViz;
    if (this.state.left) {
      leftViz = <Visualization vlSpec={this.state.left} renderer='svg' id='left'/>;
    }

    let rightViz;
    if (this.state.right) {
      rightViz = <Visualization vlSpec={this.state.right} renderer='svg' id='right'/>;
    }

    const displayClasses = classnames({
      'display': true,
      'block': this.state.chosen !== null,  // block events during confirmation
    });

    const leftClasses = classnames({
      'visualization': true,
      'chosen': this.state.chosen === LEFT,
      'hover': this.state.hover === LEFT && !(this.state.chosen === LEFT)
    });

    const equalsClasses = classnames({
      'equals': true,
      'chosen': this.state.chosen === EQUALS,
      'hover': this.state.hover === EQUALS && !(this.state.chosen === EQUALS)
    });

    const terribleClasses = classnames({
      'terrible': true,
      'chosen': this.state.chosen === TERRIBLE,
      'hover': this.state.hover === TERRIBLE && !(this.state.chosen === TERRIBLE)
    });

    const rightClasses = classnames({
      'visualization': true,
      'chosen': this.state.chosen === RIGHT,
      'hover': this.state.hover === RIGHT && !(this.state.chosen === RIGHT)
    });

    const taskClasses = classnames({
      'task': true,
      'active': !!this.state.task
    });

    const leftSpec = cleanUpSpec(this.state.left);
    const rightSpec = cleanUpSpec(this.state.right);

    let data;

    if (this.state.left) {
      const d = this.state.left.data;
      if (d.values) {
        data = d.values;
      } else {
        data = datasets[d.url];
      }
    }

    let table = '';

    if (data) {
      const l = Object.values(this.state.left.encoding).map(e => e.field).filter(d => d);
      const r = Object.values(this.state.right.encoding).map(e => e.field).filter(d => d);
      const fields = unique(l.concat(r), f => f);  // Object.keys(data[0]);

      const header = fields.map(t => <th key={t}>{t}</th>);
      const tableBody = data.slice(0, 20).map((r, i) => <tr key={i}>
        {fields.map(f => <td key={f}>{r[f]}</td>)}
      </tr>);
      const remaining = data.length - tableBody.length;

      table = <div className='table'>
        <table>
          <thead>
            <tr>
              {header}
            </tr>
          </thead>
          <tbody>
            {tableBody}
          </tbody>
        </table>
        {remaining > 0 ? <span className='remaining'>...{remaining} more rows</span> : ''}
      </div>;
    }

    const specDiff = diffJson(leftSpec, rightSpec).map((part, idx) => {
      const className = classnames({
        added: part.added,
        removed: part.removed
      });
      return <span key={idx} className={className}>{part.value}</span>;
    });

    return (
      <div className='Labeler' onMouseOut={() => {this.hover(UNK);}}>
        {this.state.user === 'anonymous' ? <div className='anonymous'>Labeling as Anonymous!<br/><span>Please add <code>?user=NAME</code> to the URL!</span></div> : ''}
        <div className={taskClasses}>Task: {this.state.task || 'NO TASK'}</div>
        <div className='chooser'>
          <div className={displayClasses}>
            <div className={leftClasses}
                  onClick={() => {this.choose(this.state.id, 'left');}}
                  onMouseEnter={() => {this.hover(LEFT);}}>
              {leftViz}
            </div>
            <div className='same'>
              <div className={equalsClasses}
                  onClick={() => {this.choose(this.state.id, 'same');}}
                  onMouseEnter={() => {this.hover(EQUALS);}}>
                <div className='indicator'>
                  {this.state.hover}
                </div>
              </div>
              <div className={terribleClasses}
                  onClick={() => {this.choose(this.state.id, 'terrible');}}
                  onMouseEnter={() => {this.hover(TERRIBLE);}}>
                Both are<br/>
                really bad
              </div>
            </div>
            <div className={rightClasses}
                onClick={() => {this.choose(this.state.id, 'right');}}
                onMouseEnter={() => {this.hover(RIGHT);}}>
              {rightViz}
            </div>
          </div>
        </div>
        <div className='specs'>
          <pre>{stringify(leftSpec, {space: 2})}</pre>
          <pre className='diff'>{specDiff}</pre>
          <pre>{stringify(rightSpec, {space: 2})}</pre>
        </div>
        { table }
      </div>
    );
  }

  hover(label) {
    this.setState({
      hover: label
    });
  }

  choose(id, label) {
    console.info(`Current cache size: ${this.state.next.length}`);

    this.setState({
      chosen: label
    });

    const message = {
      id: id,
      label: label,
      user: this.state.user
    };

    // apply next state
    let next_state, next;
    if (this.state.next.length) {
      next_state = this.state.next[0];
      next = this.state.next.slice(1);
    } else {
      next_state = {};
      next = [];
    }

    this.setState({
      id: null,
      left: null,
      right: null,
      task: null,
      chosen: null,
      ...next_state,
      next
    });

    this.fetchPairIfNecessary();

    fetch(REQUEST_PATH + 'upload_label', {
      body: JSON.stringify(message),
      method: 'post',
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json'
      },
    }).then((response) => {
      if (response.ok) {
        this.fetchPairIfNecessary();
      } else {
        alert('failed POST');
      }
    });
  }

  fetchPairIfNecessary() {
    if (this.state.next.length > 7 || this.state.requesting) {
      // still have a cache or are requesting
      return;
    }

    this.setState({requesting: true});
    fetch(REQUEST_PATH + 'fetch_pair?num_pairs=5', {
      method: 'get'
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          if (this.state.id === null) {
            if (this.state.next.length) { alert('bad state'); }

            this.setState({
              ...data[0],
              requesting: false,
              next: data.slice(1)
            });
          } else {
            this.setState({
              requesting: false,
              next: unique(this.state.next.concat(data), stringify)
            });
          }
          // we may not have fetched anything new
          this.fetchPairIfNecessary();
        });
      } else {
        console.error('failed GET');
        this.setState({requesting: false});
      }
    }).catch( e => {
      console.error(e);
      this.setState({requesting: false});
    });
  }

  handleKeyDown(event) {
    // block events during confirmation
    if (this.state.chosen === null) {
      const comparison = KEYS[event.keyCode];
      if (comparison) {
        if (comparison === this.state.hover) {
          this.setState({
            hover: UNK
          });
          this.choose(this.state.id, comparison);
        } else {
          this.hover(comparison);
        }

        event.preventDefault();
      }
    }
  }
}

export default Labeler;
