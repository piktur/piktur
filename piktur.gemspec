# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength

$LOAD_PATH.push File.expand_path('./lib', __dir__)

# Maintain your gem's version:
require 'piktur/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'piktur'
  s.version     = Piktur::VERSION
  s.authors     = ['Daniel Small']
  s.email       = ['piktur.io@gmail.com']
  s.homepage    = 'https://bitbucket.org/piktur/piktur'
  s.summary     = 'Piktur a complete Portfolio Management System for Artists'
  # s.source      = 'https://bitbucket.org/piktur/piktur_core'
  s.description = 'Common utilities for Piktur apps'
  s.license = ''
  s.bindir = 'bin'
  # Rubygems permits executable ruby scripts only, bash not accepted
  # s.executables.push(
  #   'piktur_admin.sh',
  #   'piktur_api.sh',
  #   'piktur_blog.sh',
  #   'piktur_client.sh',
  #   'piktur_client_webpack.sh'
  # )
  s.default_executable = 'piktur'
  s.files = Dir[
    'lib/**/*.rb',
    'Rakefile',
    'README.markdown'
  ]
  s.test_files = Dir['spec/**/*.rb']
  s.require_paths = %w(lib)

  # @!group Security
  # @note `dotenv` preferred over `figaro`, for `foreman` compatibility
  s.add_dependency 'dotenv',                            '~> 2.1'
  s.add_dependency 'pundit',                            '~> 1.1'
  # @!endgroup

  # @!group Utilities
  s.add_dependency 'activesupport',                     '= 4.2.5.1'
  # @!endgroup

  # @!group Server
  s.add_dependency 'puma',                              '~> 3.4'
  s.add_dependency 'foreman',                           '~> 0.81'
  # @!endgroup

  # @!group Data
  # @see https://github.com/ohler55/oj#compatibility
  # @see https://github.com/ohler55/oj/issues/199
  s.add_dependency 'oj',                                '= 2.18'
  # @!endgroup

  # @!group Frontend
  s.add_dependency 'slim',                              '~> 3.0'
  s.add_dependency 'redcarpet',                         '~> 3.3'
  # @!endgroup

  # @ Fixtures
  s.add_dependency 'faker',                             '~> 1.6'

  # @!group Test
  s.add_development_dependency 'simplecov',             '~> 0.12'
  # @!endgroup

  # @!group Development
  s.add_development_dependency 'benchmark-ips',         '~> 2.7'
  s.add_development_dependency 'byebug',                '~> 9.0'
  s.add_development_dependency 'pry',                   '~> 0.10'
  s.add_development_dependency 'pry-rails',             '~> 0.3'
  s.add_development_dependency 'pry-rescue',            '~> 1.4'
  s.add_development_dependency 'pry-stack_explorer',    '~> 0.4'
  s.add_development_dependency 'rubocop',               '~> 0.40'
  s.add_development_dependency 'spring',                '~> 1.7'
  s.add_development_dependency 'spring-commands-rspec', '~> 1.0'
  # @!endgroup

  # @!group Documentation
  s.add_development_dependency 'yard',                  '~> 0.8'
  # @!endgroup
end
