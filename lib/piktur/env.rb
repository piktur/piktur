# frozen_string_literal: false

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
# Push to host with the following command.
#
# ```
#   # Heroku CLI
#   $ heroku config:set $(cat .env.common .env)
#
#   # AWS ElasticBeanstalk CLI
#   $ eb setenv $(cat .env.common .env)
# ```
#
# @example
#   N = 1000
#   Benchmark.bmbm do |x|
#     x.report :bash do
#       N.times { `echo $(cat ../.env.common)` }
#     end
#     x.report :ruby do
#       N.times { File.read('../.env.common') }
#     end
#   end
#
#   Rehearsal ----------------------------------------
#   bash   0.050000   0.320000   4.090000 (  4.220029)
#   ruby   0.010000   0.010000   0.020000 (  0.015098)
#   ------------------------------- total: 4.110000sec
#              user     system      total        real
#   bash   0.050000   0.290000   4.080000 (  4.211515)
#   ruby   0.000000   0.010000   0.010000 (  0.007821)
#
require 'dotenv'

module Piktur

  # @example
  #   echo $(cat #{flist.join(' ')})`.chomp
  #   flist.each_with_object(String.new('')) { |e, a| a << File.read(e) }  # .gsub(/\n/, ', ')
  # @params [Boolean] vlist Print values
  # @params [String] args List of files containing key value pairs
  # @return [String]
  # @return [Array] if `vlist` false
  def self.env(*args, vlist: true)
    # Load `env.common` first, subsequent files should overload values if keys match
    args.unshift('.env.common') unless args.include?('.env.common')

    flist = args.collect! do |fname|
      file = Piktur.dev_path.join(fname)
      file if file.exist?
    end.compact

    return flist unless vlist

    flist.collect! { |e| File.read(e) }.join # .gsub(/\n/, ', ')
  end

end

unless ENV['CIRCLECI'] || ENV['CI']
  env   = ENV['RAILS_ENV'] ||= ENV['RACK_ENV'] ||= 'development'
  files = Piktur.env(env == 'production' ? '.env' : ".env.#{env}", vlist: false)
  Dotenv.overload(*files)
end
