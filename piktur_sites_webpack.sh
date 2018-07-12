#!/bin/bash

cd ../piktur_sites

# source "/usr/local/bin/npm"

# Start Webpack Development Server with Hot Module Replacement enabled
node_modules/.bin/webpack --config webpack.config.development.babel.js
# node_modules/.bin/webpack-dev-server --hot --inline --config webpack.config.development.babel.js
