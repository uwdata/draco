import React, { Component } from 'react';
import { Redirect } from 'react-router'

import 'index/scss/ToolTile.css';

class ToolTile extends Component {
  constructor(props) {
    super(props);
    this.state = {
      redirect: false,
    };
  }

  render() {
    if (this.state.redirect) {
      return <Redirect push to={this.props.route}/>
    }
    return (
      <div className="ToolTile" onClick={this.redirect.bind(this)}>
        <div className="name">
          {this.props.name}
        </div>
        <div className="description">
          {this.props.description}
        </div>
      </div>
    );
  }

  redirect() {
    this.setState({
      redirect: true
    });
  }
}

export default ToolTile;
