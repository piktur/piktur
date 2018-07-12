#!/bin/bash

cd ../piktur_sites

# Ensure correct gemset is in use! If env var $rvm_bin_path is guaranteed to
# exist use `$rvm_bin_path use gemset ruby-2.3.0@piktur`, otherwise
source "$HOME/.rvm/scripts/rvm"
rvm use gemset ruby-${RUBY_VERSION}@piktur

# bundle install

# Start Piktur Client development server
bin/bundle exec puma -p ${PIKTUR_CLIENT_PORT}
