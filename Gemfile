# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength, Style/ExtraSpacing

gh = 'https://github.com'
bb = 'https://bitbucket.org'

source 'https://rubygems.org'
ruby '2.3.0'

gemspec name: 'piktur'

# @note Use of `require: false` prevents loading gem on application boot.
#   Require strategically within relevant file(s).

# @!group Security
gem 'rack_auth_jwt',            git:     "#{bb}/piktur/rack_auth_jwt.git",
                                branch:  'master',
                                require: false
# @!endgroup

# @!group Documentation
gem 'yard',                     git:     "#{gh}/lsegal/yard.git",
                                branch:  'master',
                                require: false
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
  gem 'pry',                    require: true
  gem 'pry-rails',              require: true
  gem 'pry-rescue',             require: true
  gem 'pry-stack_explorer',     require: true
end

group :test do
  gem 'simplecov',              require: false
end

group :production do
  gem 'newrelic_rpm',           require: true
  gem 'rails_12factor',         require: true
end
