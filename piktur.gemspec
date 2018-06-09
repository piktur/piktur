# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

$LOAD_PATH.push File.expand_path('./lib', __dir__)

require_relative './lib/piktur/version.rb'

Gem::Specification.new do |s|
  s.name        = 'piktur'
  s.version     = Piktur::VERSION
  s.authors     = ['Daniel Small']
  s.email       = ['piktur.io@gmail.com']
  s.homepage    = 'https://bitbucket.org/piktur/piktur'
  s.summary     = 'Piktur a complete Portfolio Management System for Artists'
  # s.source      = 'https://bitbucket.org/piktur/piktur_core'
  s.description = 'Common utilities for Piktur apps'
  s.license     = ''
  # @note Rubygems permits executable ruby scripts only, bash scripts ie.
  #   `s.executables.push('piktur_admin.sh')` not accepted
  s.files = Dir[
    '{bin,lib}/**/*.rb',
    '.rubocop.yml',
    '.yardopts',
    'circle.yml',
    'DEPLOY.markdown',
    'DEVELOPMENT.markdown',
    'Gemfile',
    'init.development.sh',
    'piktur*.sh',
    'piktur.gemspec',
    'Procfile',
    'Rakefile',
    'README.markdown'
  ]
  s.test_files    = Dir['spec/**/*.rb']
  s.require_paths = %w(lib)
  s.bindir        = 'bin'

  # @!group Security
  # @note `dotenv` preferred over `figaro`, for `foreman` compatibility
  s.add_dependency 'dotenv',                            '~> 2.1'
  # @!endgroup

  # @!group Utilities
  s.add_dependency 'fast_underscore',                   '~> 0.3'
  s.add_dependency 'activesupport',                     "= #{ENV.fetch('RAILS_VERSION')}"
  s.add_dependency 'dry-configurable',                  '~> 0.7'
  s.add_dependency 'dry-monads',                        '~> 0.3'
  s.add_dependency 'dry-struct',                        '~> 0.4', '< 0.5'
  s.add_dependency 'dry-types',                         '~> 0.12'
  s.add_dependency 'dry-transaction',                   '~> 0.1'
  s.add_dependency 'rake',                              '~> 12.0'
  # @!endgroup

  # @!group Server
  s.add_dependency 'foreman',                           '~> 0.8'
  s.add_dependency 'puma',                              '~> 3.4'
  # @!endgroup

  # @!group Data
  # @see https://github.com/ohler55/oj#compatibility
  # @see https://github.com/ohler55/oj/issues/199
  s.add_dependency 'oj',                                '~> 3.5'
  # @!endgroup

  # @!group Frontend
  s.add_dependency 'redcarpet',                         '~> 3.0'
  s.add_dependency 'slim',                              '~> 3.0'
  # @!endgroup

  s.add_dependency 'newrelic_rpm',                      '~> 3.17'

  # @!group Documentation
  s.add_development_dependency 'yard',                              '~> 0.8'
  # @!endgroup

  # @!group Development
  # @note `add_development_dependency` does not make the library available to dependent libraries.
  #   Instead wrap these libraries in a `group` block within `Gemfile`
  s.add_development_dependency 'awesome_print',                     '~> 1.7'
  # @!endgroup

  # @!group Testing
  s.add_development_dependency 'faker',                             '~> 1.6'
  s.add_development_dependency 'listen',                            '>= 3.0.5', '< 3.2'
  s.add_development_dependency 'rspec',                             '~> 3.7'
  s.add_development_dependency 'simplecov',                         '~> 0.12'
  s.add_development_dependency 'spring',                            '~> 2.0'
  s.add_development_dependency 'spring-watcher-listen',             '~> 2.0'
  # @!endgroup

  # @!group Debug
  s.add_development_dependency 'pry',                               '~> 0.10'
  s.add_development_dependency 'pry-rescue',                        '~> 1.4'
  s.add_development_dependency 'pry-stack_explorer',                '~> 0.4'
  # @!endgroup

  # @!group Code Quality
  s.add_development_dependency 'rubocop',                           '~> 0.50'
  # @!endgroup

  # @!group Benchmarks
  s.add_development_dependency 'benchmark-ips',                     '~> 2.7'
  s.add_development_dependency 'ruby-prof',                         '~> 0.1'
  s.add_development_dependency 'hotch',                             '~> 0.5'
  # @!endgroup
end
