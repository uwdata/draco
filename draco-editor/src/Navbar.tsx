import * as classNames from 'classnames';
import * as React from 'react';
import { NavLink } from "react-router-dom";

import './Navbar.css';


const LEFT_TABS = ['editor'];
const RIGHT_TABS = ['about'];
const HOME_ROUTE = 'editor';


class Navbar extends React.Component<any, any> {
  public render() {
    const leftTabs = LEFT_TABS.map((name) => {
      const route = name === HOME_ROUTE ? '' : name;
      return (
        <NavLink to={`/${route}`}
          exact
          activeClassName="selected"
          className="tab" key={name}>
          {name}
        </NavLink>
      );
    });

    const rightTabs = RIGHT_TABS.map((name) => {
      const route = name === HOME_ROUTE ? '' : name;
      return (
        <NavLink to={`/${route}`}
          exact
          activeClassName="selected"
          className="tab" key={name}>
          {name}
        </NavLink>
      );
    });

    return (
      <div className="Navbar">
        <div className="tabs left">
          {leftTabs}
        </div>
        <div className="title">
          Draco
        </div>
        <div className="tabs right">
          {rightTabs}
        </div>
      </div>
    );
  }
}

export default Navbar;
