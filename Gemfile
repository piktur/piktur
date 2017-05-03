# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength, Style/ExtraSpacing

# @note RubyGems doesn't tolerate unbuilt dependencies from git sources. Private gems are
#   instead served privately with `geminabox`.
# @see https://bitbucket.org/snippets/piktur/dBKR5 require private BitBucket repo

bb = 'https://bitbucket.org'

# source 'https://rubygems.org'
source ENV['GEM_SOURCE']

ruby ENV.fetch('RUBY_VERSION').sub('ruby-', '')

gemspec name: 'piktur'

# @note `require: false` defers loading. Require strategically within codebase.

# @!group Security
# @note `dotenv` preferred over `figaro`, for `foreman` compatibility
gem 'dotenv'
# git: "#{bb}/piktur/knock.git", branch: 'master'
gem 'knock',                    source: ENV['GEM_SOURCE']
# git: "#{bb}/piktur/rack_auth_jwt.git", branch: 'master'
gem 'rack_auth_jwt',            source:  ENV['GEM_SOURCE'],
                                require: 'rack/auth/jwt'
# @!endgroup

# @!group Utilities
gem 'activesupport',            require: false
gem 'rake'
# @!endgroup

# @!group Server
gem 'foreman',                  require: false
gem 'puma',                     require: false
# @!endgroup

# @!group Documentation
gem 'yard',                     source: ENV['GEM_SOURCE']
# @!endgroup

# @!group Frontend
gem 'redcarpet',                require: false
gem 'slim',                     require: false
# @!endgroup

group :development do
  gem 'byebug',                 require: false
  gem 'rubocop',                require: false
end

group :development, :test do
  gem 'awesome_print',          source:  ENV['GEM_SOURCE'],
                                require: false
  gem 'benchmark-ips',          require: false
  gem 'faker'
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'simplecov',              require: false
end

group :production do
  gem 'newrelic_rpm'
end
