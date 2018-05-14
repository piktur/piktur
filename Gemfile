# frozen_string_literal: true

# rubocop:disable ExtraSpacing

bb = 'https://bitbucket.org'

# @note RubyGems will not load unbuilt dependencies from git sources. Private gems are
#   instead served with `geminabox`.
# @see https://bitbucket.org/snippets/piktur/dBKR5 require private BitBucket repo

# source 'https://rubygems.org'
source ENV['GEM_SOURCE']

ruby ENV.fetch('RUBY_VERSION').sub('ruby-', '')

gemspec name: 'piktur'

# @note `require: false` defers loading. Require strategically within codebase.

# @note `dotenv` preferred over `figaro`, for `foreman` compatibility
gem 'dotenv'

# C extension to replace ActiveSupport::Inflector.underscore
gem 'fast_underscore',          require: false

gem 'piktur_security',          git:    "#{bb}/piktur/piktur_security.git",
                                branch: 'rails5'
gem 'piktur_spec',              git:    "#{bb}/piktur/piktur_spec.git",
                                branch: 'master'

# @!group Utilities
gem 'activesupport',            require: false
gem 'dry-configurable',         require: false
gem 'dry-monads',               require: false
gem 'dry-struct',               require: false
gem 'dry-types',                require: false
gem 'dry-transaction',          require: false
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
  gem 'rubocop',                require: false
end

group :development, :test do
  gem 'awesome_print',          source:  ENV['GEM_SOURCE'],
                                require: false
  gem 'benchmark-ips',          require: false
  gem 'byebug',                 require: false
  gem 'faker'
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'ruby-prof',              require: false
end

group :test do
  gem 'simplecov',              require: false
end

group :production do
  gem 'newrelic_rpm'
end
