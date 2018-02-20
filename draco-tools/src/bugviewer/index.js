import React from 'react';
import ReactDOM from 'react-dom';
import 'bugviewer/scss/index.css';
import App from 'bugviewer/js/components/App';
import registerServiceWorker from 'bugviewer/js/utilities/registerServiceWorker';

ReactDOM.render(<App />, document.getElementById('root'));
registerServiceWorker();
