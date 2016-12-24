#!/bin/bash

cd ./piktur_api

# Ensure correct gemset is in use! If env var $rvm_bin_path is guaranteed to
# exist use `$rvm_bin_path use gemset ruby-2.3.0@piktur`, otherwise
source "$HOME/.rvm/scripts/rvm"
rvm use gemset ruby-2.3.0@piktur

bundle install

# Start Sidekiq background job manager
# bundle exec sidekiq

# Start Piktur API development server
bundle exec puma -p ${PIKTUR_API_PORT}