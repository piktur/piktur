# frozen_string_literal: true

module Piktur

  # @todo Host secrets privately or store encrypted files on git [task](https://trello.com/c/iymYXp4X/203-env)
  #
  # Set ENV variables from values contained in local files
  #
  # ## Environment Configuration
  #
  # @note DO NOT COMMIT `.env` TO SOURCE CONTROL
  #
  # `dotenv` preferred -- both it and `foreman` will pickup variables defined within `.env` files.
  # `.env` files are stored locally within piktur root directory.
  #
  # `foreman` may be used to load variables locally or otherwise run
  #
  # ```bash
  #   $ export $(cat .env.common .env.$RAILS_ENV)
  # ```
  #
  # For remote environments push with:
  #   * Heroku `$ heroku config:set $(cat .env.common .env)`
  #   * AWS ElasticBeanstalk CLI `$ eb setenv $(cat .env.common .env)`
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
  module Secrets

    # Return existent paths
    # @example
    #   echo $(cat #{flist.join(' ')})`.chomp
    #   flist.each_with_object(String.new('')) { |e, a| a << File.read(e) }
    # @param [String] args File list
    # @raise [Errno::ENOENT] if file missing
    # @return [Array<Pathname>]
    def self.flist(*args)
      # Load `env.common` first, subsequent files MUST overload matching keys
      args.unshift('.env.common') unless args == '.env.common'
      args.collect do |fname|
        file = ::Piktur.root.parent.join(fname)
        raise Errno::ENOENT, file unless file.exist?
        file
      end
      args.compact!
      args
    end

    # Return concatenated variables contained in existent files
    # @param [String] args File list
    # @return [String]
    def self.vlist(*args)
      flist(args).collect { |e| File.read(e) }.join
    end

    # Default filename for environment
    # @return [String]
    def self.default
      case ::Piktur.env
      when 'production'   then '.env'
      when 'development'  then '.env.development'
      when 'staging'      then '.env.staging'
      when 'test'         then '.env.test'
      end
    end

    # Overload ENV variables
    # @return [true] unless CI
    def self.overload
      return if ENV['CIRCLECI'] || ENV['CI']
      require 'dotenv'
      ::Dotenv.overload(*flist(default))
      true
    end

  end

end
