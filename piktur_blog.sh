#!/bin/bash

cd ./piktur_blog

source '/usr/local/bin/npm'

# Start Piktur Blog development server
# @note Ghost supports LTS Node versions only, to circumvent version constraint
# set 'GHOST_NODE_VERSION_CHECK' environment variable to false
# @see http://blog.z-proj.com/running-ghost-with-node-v5/
GHOST_NODE_VERSION_CHECK=false exec npm start --${NODE_ENV}

