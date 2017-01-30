#!/bin/bash
#
# This Procfile will start services required by production environment
#   - admin
#   - admin webpack
#   - api
#   - blog
#   - client
#   - client webpack
#
# Following example of Service Oriented Architecture (SOA) whereby multiple
# Rails applications may be coordinated.
# @see https://blog.engineyard.com/2014/better-soa-development-with-foreman-and-nginx
#
# @note It is often the case that processes are not properly terminated when
# foreman is stopped with Ctrl+C. If this is the case, and you are unable to
# start a new server instance because the port is already taken, first
# identify running process and kill it.
# @example
#   $ losf -i :<PORT>
#   $ kill -9 <PID>
#
# @note ./init.development.sh deals with this now. Just be sure to run it before starting foreman.
#
# @example Start development environment
#   # Start redis-server a separate shell
#   /usr/local/bin/redis-server /usr/local/etc/redis.conf
#
#   # Ensure relevant ports are clear
#   ./init.development.sh
#
#   # Then start Foreman
#   foreman start -e ../.env.common,../.env.development
#
# @example Start production environment
#   foreman start -e .env.common,.env
#
# @see https://github.com/ddollar/foreman/wiki/Custom-Signals Sending custom signals
# @example
#   trap TERM and change to QUIT
#   trap 'echo killing $PID; kill -QUIT $PID' TERM
#
#   program to run
#   command &
#
#   capture PID and wait
#   PID=$!
#   wait

web1:    ./piktur_admin.sh
web2:    ./piktur_api.sh
# web3:    ./piktur_blog.sh
# web4:    ./piktur_client.sh
worker1: ./piktur_admin_webpack.sh
# worker2: ./piktur_client_webpack.sh
worker3: redis-server
worker4: cd ../piktur_api; bundle exec sidekiq