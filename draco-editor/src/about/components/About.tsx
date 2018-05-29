import * as React from 'react';

import '../styles/About.css';

import logo from '../../images/logo-dark.svg';

export default class About extends React.Component<any, any> {
  render() {
    return (
      <div className="About">
        <img src={logo} className="logo" height={128} />
        <p>
          Draco is a system aimed at recommending visualizations.
        </p>
        <p>
          Source code can be found <a href="https://github.com/domoritz/draco">on github</a>.
        </p>
      </div>
    )
  }
}
