import * as React from 'react';
import './Navbar.css';

import * as classNames from 'classnames';

const LEFT_TABS = ['editor', 'configurer'];
const RIGHT_TABS = ['about'];

interface Props {
  currTab: string;
}

class Navbar extends React.Component<Props, any> {
  constructor(props: Props) {
    super(props);
  }

  public render() {
    const leftTabs = [];
    for (const name of LEFT_TABS) {
      const tabClass = classNames({
        'selected': this.props.currTab === name,
        'tab': true,
      });

      leftTabs.push(
        <div className={tabClass} key={name}>{name}</div>
      )
    }

    const rightTabs = [];
    for (const name of RIGHT_TABS) {
      const tabClass = classNames({
        'selected': this.props.currTab === name,
        'tab': true,
      });

      rightTabs.push(
        <div className={tabClass} key={name}>{name}</div>
      )
    }

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