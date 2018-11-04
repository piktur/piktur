# frozen_string_literal: true

# rubocop:disable ExtraSpacing

gh = 'https://github.com'
bb = 'https://bitbucket.org'

# @note RubyGems will not load unbuilt dependencies from git sources. Private gems are
#   instead served with `geminabox`.
# @see https://bitbucket.org/snippets/piktur/dBKR5 require private BitBucket repo

source ENV.fetch('GEM_SOURCE') { 'https://rubygems.org' }

ruby ENV.fetch('RUBY_VERSION').sub('ruby-', '')

gemspec

# @note `require: false` defers loading. Require strategically within codebase.

# @note `dotenv` preferred over `figaro`, for `foreman` compatibility
gem 'dotenv'

# C extension to replace ActiveSupport::Inflector.underscore
gem 'fast_underscore',          require: false

# @!group Utilities
gem 'activesupport',            require: false
gem 'concurrent-ruby',          git:    "#{gh}/ruby-concurrency/concurrent-ruby.git",
                                branch: 'master'
gem 'dry-auto_inject',          require: false
gem 'dry-configurable',         require: false
gem 'dry-monads',               require: false
gem 'dry-struct',               require: false
gem 'dry-types',                require: false
gem 'dry-transaction',          require: false
gem 'rake',                     require: false
# @!endgroup

# @!group Server
gem 'foreman',                  require: false
gem 'puma',                     require: false
# @!endgroup

# @!group Frontend
gem 'redcarpet',                require: false
gem 'slim',                     require: false
# @!endgroup

group :benchmark do
  gem 'benchmark-ips'
  gem 'ruby-prof',              require: false
  gem 'hotch',                  require: false
end

group :development do
  gem 'solargraph'
  gem 'rubocop'
  gem 'yard',                   require: false
end

group :development, :test do
  gem 'faker',                  require: false
  gem 'piktur_spec',            git:     "#{bb}/piktur/piktur_spec.git",
                                branch:  'master'
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'fakefs',                 require: false
  gem 'rspec'
  gem 'simplecov',              require: false
end

group :production do
  gem 'newrelic_rpm'
end
