#!/usr/bin/env puma

# Default Puma web server configuration, shared by
#
# Preferred port is specified in Procfile
# @example
#   api: sh -c "cd piktur_api && bundle exec puma -p 3000"
#   admin: sh -c "cd piktur_admin && bundle exec puma -p 3001"

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
threads_count = Integer ENV.fetch('RAILS_MAX_THREADS', 5)
threads threads_count, threads_count

# pidfile File.join(ENV.fetch('PWD'), 'tmp/pids/server.pid')
# rackup DefaultRackup

environment ENV.fetch('RAILS_ENV', 'development')

workers Integer ENV.fetch('WEB_CONCURRENCY', 2)

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
preload_app!

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: {https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot}
  # Establish database conntection when ActiveRecord loaded
  ActiveSupport.on_load(:active_record) do
    ::Piktur.debug(binding, warn: 'Ensure connection to ROM gateway established!')

    # ROM.env.gateways[:default].connect

    # ActiveRecord::Base.establish_connection
  end
end

on_worker_shutdown do
  # Disconnect from Redis before it's shutdown. Avoiding Redis::CannotConnectError
  Sidekiq.redis(&:disconnect!) if defined?(Sidekiq)
end

# If you're preloading your application and using ActiveRecord, it's recommended that you close
# any connections to the database here to prevent connection leakage.
before_fork do
  ::Piktur.debug(binding, warn: 'Ensure connection to ROM gateway disconnected!')

  # ROM.env.gateways[:default].disconnect

  # ActiveRecord::Base.establish_connection.disconnect!
  Sidekiq.redis(&:disconnect!) if defined?(Sidekiq)
end

# on_restart do
# end