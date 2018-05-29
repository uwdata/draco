const path = require('path');
const merge = require('webpack-merge');
const common = require('./webpack.common.js');
const webpack = require('webpack');

module.exports = merge(common, {
  mode: 'production',
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "dist"),
    publicPath: '/draco/'
  },

  plugins: [
    // base route
    new webpack.DefinePlugin({
      BASENAME: JSON.stringify("/")
    }),
  ],
});
