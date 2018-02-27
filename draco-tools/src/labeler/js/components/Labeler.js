import 'labeler/scss/Labeler.css';

import React, { Component } from 'react';
import Visualization from 'shared/js/components/Visualization';
import { duplicate } from 'vega-lite/build/src/util';
import * as stringify from 'json-stable-stringify';

const classnames = require('classnames');

const UNK = '?';
const LEFT = '>';
const EQUALS = '=';
const RIGHT = '<';

const KEYS = {
  37: '>', 40: '=', 39: '<',
};

const CONFIRMATION_TIME = 500;
const REQUEST_PATH = 'http://0.0.0.0:5000/pair';

function cleanUpSpec(spec) {
  if (!spec) {
    return spec;
  }

  spec = duplicate(spec);
  delete spec.data;
  return spec;
}

class Labeler extends Component {
  constructor(props) {
    super(props);
    this.state = {
      id: null,
      left: null,
      right: null,
      chosen: null,
      hover: UNK,
    };
  }

  componentDidMount() {
    this.fetchPair();
    document.body.addEventListener('keydown', this.handleKeyDown.bind(this));
  }

  componentWillUnMount() {
    document.body.removeEventListener('keyup', this.handleKeyDown.bind(this));
  }

  render() {
    let leftViz;
    if (this.state.left) {
      leftViz = <Visualization vlSpec={this.state.left} id="left"/>
    }

    let rightViz;
    if (this.state.right) {
      rightViz = <Visualization vlSpec={this.state.right} id="right"/>
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

    const rightClasses = classnames({
      'visualization': true,
      'chosen': this.state.chosen === RIGHT,
      'hover': this.state.hover === RIGHT && !(this.state.chosen === RIGHT)
    });


    return (
      <div className="Labeler" onMouseOut={() => {this.hover(UNK)}}>
        <div className="chooser">
          <div className={displayClasses}>
            <div className={leftClasses}
                  onClick={() => {this.choose(this.state.id, LEFT)}}
                  onMouseEnter={() => {this.hover(LEFT)}}>
              {leftViz}
            </div>
            <div className={equalsClasses}
                onClick={() => {this.choose(this.state.id, EQUALS)}}
                onMouseEnter={() => {this.hover(EQUALS)}}>
              <div className="indicator">
                {this.state.hover}
              </div>
            </div>
            <div className={rightClasses}
                onClick={() => {this.choose(this.state.id, RIGHT)}}
                onMouseEnter={() => {this.hover(RIGHT)}}>
              {rightViz}
            </div>
          </div>
        </div>
        <div className="specs">
          <pre>{stringify(cleanUpSpec(this.state.left), {space: 2})}</pre>
          <div></div>
          <pre>{stringify(cleanUpSpec(this.state.right), {space: 2})}</pre>
        </div>
        <div>Task:</div>
      </div>
    );
  }

  hover(label) {
    this.setState({
      hover: label
    });
  }

  choose(id, label) {
    this.setState({
      chosen: label
    });

    const message = {
      id: id,
      label: label
    };

    fetch(REQUEST_PATH, {
      body: JSON.stringify(message),
      method: 'post',
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json'
      },
    }).then((response) => {
      if (response.ok) {
        // on success, fetch another pair
        setTimeout(() => {
          this.fetchPair();
        }, CONFIRMATION_TIME);
      } else {
        alert('failed POST');
      }
    });
  }

  fetchPair() {
    fetch(REQUEST_PATH, {
      method: 'get'
    }).then((response) => {
      if (response.ok) {
        response.json().then((data) => {
          this.setState({
            id: data.id,
            left: data.left,
            right: data.right,
            chosen: null,
            hover: UNK,
          });
        });
      } else {
        alert('failed GET');
      }
    });
  }

  handleKeyDown(event) {
    // block events during confirmation
    if (this.state.chosen === null) {
      const comparison = KEYS[event.keyCode];
      if (comparison) {
        if (comparison === this.state.hover) {
          this.choose(this.state.id, comparison);
        } else {
          this.hover(comparison);
        }
      }
    }
  }
}

export default Labeler;
