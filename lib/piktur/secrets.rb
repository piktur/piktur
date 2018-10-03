# frozen_string_literal: true

module Piktur

  # @deprecated
  #
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
  # ```bash
  #   $ export $(cat .env.common .env.$RAILS_ENV)
  # ```
  #
  # For remote environments push with:
  #   * Heroku `$ heroku config:set $(cat .env.common .env)`
  #   * AWS ElasticBeanstalk CLI `$ eb setenv $(cat .env.common .env)`
  #
  module Secrets

    # Return existent paths
    #
    # @example
    #   echo $(cat #{flist.join(' ')})`.chomp
    #   flist.each_with_object(String.new('')) { |e, a| a << File.read(e) }
    #
    # @param [String] args File list
    #
    # @raise [Errno::ENOENT] if file missing
    # @return [Array<Pathname>]
    def self.flist(*args)
      # Load `env.common` first, subsequent files MUST overload matching keys
      args.unshift('.env.common') unless args == '.env.common'
      args.collect do |fname|
        file = parent.root.parent.join(fname)
        raise Errno::ENOENT, file unless file.exist?

        file
      end
      args.compact!
      args
    end

    # Return concatenated variables contained in existent files
    #
    # @param [String] args File list
    # @return [String]
    def self.vlist(*args)
      flist(args).collect { |e| File.read(e) }.join
    end

    # Default filename for environment
    #
    # @return [String]
    def self.default
      case parent.env
      when 'production'   then '.env'
      when 'development'  then '.env.development'
      when 'staging'      then '.env.staging'
      when 'test'         then '.env.test'
      end
    end

    # Overload ENV variables
    #
    # @return [true] unless CI
    def self.overload
      return if ENV['CIRCLECI'] || ENV['CI']

      require 'dotenv'
      ::Dotenv.overload(*flist(default))
      true
    end

  end

end
