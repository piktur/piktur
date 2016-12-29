# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength, Style/ExtraSpacing

gh = 'https://github.com'
bb = 'https://bitbucket.org'

source 'https://rubygems.org'
source 'http://localhost:9292'

ruby '2.3.0'

gemspec name: 'piktur'

# @note `require: false` defers loading. Require strategically within codebase.

# @!group Security
# @note `dotenv` preferred over `figaro`, for `foreman` compatibility
gem 'dotenv'
# gem 'knock',                    git:    "#{bb}/piktur/knock.git",
#                                 branch: 'master'
# gem 'rack_auth_jwt',            git:     "#{bb}/piktur/rack_auth_jwt.git",
#                                 branch:  'master',
#                                 require: 'rack/auth/jwt'
gem 'rack_auth_jwt',            source:  'http://localhost:9292',
                                require: 'rack/auth/jwt'
# @!endgroup

# @!group Utilities
gem 'activesupport',            require: false
# @!endgroup

# @!group Server
gem 'foreman',                  require: false
gem 'puma',                     require: false
# @!endgroup

# @!group Documentation
gem 'yard',                     git:    "#{gh}/lsegal/yard.git",
                                branch: 'master'
# @!endgroup

# @!group Frontend
gem 'redcarpet',                require: false
gem 'slim',                     require: false
# @!endgroup

group :development do
  gem 'annotate',               git:     "#{gh}/noname00000123/annotate_models.git",
                                branch:  'develop',
                                require: false
  gem 'byebug',                 require: false
  gem 'rubocop',                require: false
end

group :development, :test do
  gem 'awesome_print',          git:     "#{gh}/awesome-print/awesome_print.git",
                                branch:  'master',
                                require: false
  gem 'benchmark-ips',          require: false
  gem 'faker',                  require: false
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'simplecov',              require: false
end

group :production do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end
