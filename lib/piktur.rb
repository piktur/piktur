# frozen_string_literal: true

require 'pathname'
%w(
  dependencies
  dependencies/autoload
  core_ext/string/inquiry
  core_ext/hash/keys
  core_ext/module/delegation
).each { |f| require "active_support/#{f}" }

# Basic config/utilities for Piktur applications.
# `piktur` must remain portable.
#
#   * Minimize **redundancy**
#   * Maintain **separation of concerns**
#   * Be DRY
#
# @see https://trello.com/c/gcytwRuV/79-decouple-core-dependencies
# @see https://bitbucket.org/piktur/piktur_core/issues/21/decouple-core-dependencies #21
#
module Piktur

  extend ::ActiveSupport::Autoload

  eager_autoload do
    autoload :Services
    autoload :Secrets
    autoload :Support
  end

  autoload :Cache

  class << self

    # Returns absolute path to root directory
    #
    # @return [Pathname]
    def root
      ::Pathname.new(__dir__).parent
    end

    # @return [Piktur::Environment]
    def env
      Environment.instance
    end

    # @return [Piktur::Config]
    def config; Piktur::Config.config; end

    # @return [Services::Index]
    def services; config.services; end

    # Returns Service object for current application
    #
    # @return [Services::Service]
    def application; services.application; end

    # @return [Array<Services::Application>]
    def applications; services.applications; end

    # @return [Array<Services::Engine>]
    def engines; services.engines; end

    # @return [Array<Services::Library>]
    def libraries; services.libraries; end

    # @return [Array<Rails::Railtie>]
    def railties; services.railties; end

    # @return [Services::Index]
    def dependencies; services.dependencies; end

    # Remote server metadata for {.services}
    #
    # @return [Services::Servers]
    def servers; services.servers; end

    # Base domain for {.services}
    # @return [Object]
    def domain; servers.domain; end

    # @!method eager_load_namespaces
    #   @return [Array<Module, Class>]
    def eager_load_namespaces; services.eager_load_namespaces; end

    # Returns the canonical file index for all loaded {.services}
    #
    # @return [Piktur::Services::FileIndex]
    def files; services.file_index; end
    alias file_index files

  end

  # @todo A proper production solution will have to be implemented.
  #   For development, use bin/env to load variables from local **untracked** files.
  # Secrets.overload

  # Install the optimised Inflector immediately
  Support.install(:inflector)

end

require_relative './piktur/env.rb'
require_relative './piktur/debugger.rb'
require_relative './piktur/logger.rb'
require_relative './piktur/config.rb'
