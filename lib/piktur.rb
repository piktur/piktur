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
    autoload :Secrets,     'piktur/env'
    autoload :Environment, 'piktur/env'
    autoload :Support
  end

  autoload :Config
  autoload :Cache

  class << self

    # Returns absolute path to root directory
    # @return [Pathname]
    def root
      Pathname.new(File.expand_path('../', __dir__))
    end

    # @return [Piktur::Environment]
    def env
      Environment.instance
    end

    # @!method config
    #   @return [Piktur::Config]
    # @!method configure(&block)
    #   @return [void]
    delegate :config, to: 'Piktur::Config'

    # @!method services
    #   @return [Services::Index]
    delegate :services, to: :config

    # @!method application
    #   Returns Service object for current application
    #   @return [Services::Service]
    delegate :application, to: :services

    # @!method applications
    # @!method engines
    # @!method libraries
    # @return [Array<Services::Service>]
    delegate :applications, :engines, :libraries, to: :services

    # @!method railties
    #   @return [Array<Class>]
    delegate :railties, to: :services

    # @!method dependencies
    #   @return [Services::Index]
    delegate :dependencies, to: :services

    # @!method servers
    #   Remote server metadata for Piktur services
    #   @return [Services::Servers]
    delegate :servers, to: :services

    # @!method domain
    #   Base domain for Piktur services
    #   @return [Object]
    delegate :domain, to: :servers

    # @!method eager_load_namespaces
    #   @return [Array<Module, Class>]
    delegate :eager_load_namespaces, to: :services

  end

  Secrets.overload

  require 'pry' unless env.production?

end

require_relative './piktur/config.rb'
