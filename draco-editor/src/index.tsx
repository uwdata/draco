import * as React from 'react';
import * as ReactDOM from 'react-dom';

import App from './App';
import './index.css';

declare var Module: any;

ReactDOM.render(
  <App />,
  document.getElementById('root') as HTMLElement
);
