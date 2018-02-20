import React, { Component } from 'react';
import 'index/scss/ToolTile.css';

class ToolTile extends Component {
  render() {
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
    window.location.href = '/' + this.props.url;
  }
}

export default ToolTile;
