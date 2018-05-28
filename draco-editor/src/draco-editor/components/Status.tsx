import * as React from "react";

import "../styles/Status.css";

interface Props {
  status: string;
}

export default class Status extends React.PureComponent<Props> {
  public render() {
    let className = "Status";
    if (!!this.props.status) {
      className += " active";
    }

    return <div className={className}>{this.props.status}</div>;
  }
}
