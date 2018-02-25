import React from 'react';
import ReactDOM from 'react-dom';
import App from 'index/js/components/App';
import registerServiceWorker from 'index/js/utilities/registerServiceWorker';

ReactDOM.render(<App />, document.getElementById('root'));
registerServiceWorker();
