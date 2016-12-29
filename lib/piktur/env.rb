# frozen_string_literal: true

# ## Environment Configuration
#
# `dotenv` preferred over `figaro`, for `foreman` compatibility -- both refer to `.env`.
#
# @example
#   `export $(cat .env.common .env.$RAILS_ENV)` unless ENV['CIRCLECI'] || ENV['CI']
#
# Variables are defined in `.env` files within piktur root directory.
#
# .env files are not under source control use `foreman` to load variables locally.
#
# Push to heroku with the following command.
#
# ```
#   $ heroku config:set $(cat .env.common .env)
# ```
require 'dotenv'

unless ENV['CIRCLECI'] || ENV['CI']
  env = ENV['RAILS_ENV'] ||= ENV['RACK_ENV'] ||= 'development'

  # Load `.env.<environment>` **AFTER** `env.common` so that matching keys are overloaded.
  files = %w(.env.common)
  files << (env == 'production' ? '.env' : ".env.#{env}")
  files.collect! do |fname|
    path = File.expand_path("../#{fname}", ENV['PWD'])
    File.exist? path
  end
  files.compact

  Dotenv.overload(*files)
end
