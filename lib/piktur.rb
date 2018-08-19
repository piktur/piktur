# frozen_string_literal: true

require 'pathname'
%w(
  dependencies
  dependencies/autoload
  core_ext/string/inquiry
  core_ext/hash/keys
  core_ext/module/delegation
).each { |f| require "active_support/#{f}" }

# Reusable configuration and utility modules for Piktur applications.
# Use {.install} to expose this interface within your application.
#
# @see https://trello.com/c/gcytwRuV/79-decouple-core-dependencies
# @see https://bitbucket.org/piktur/piktur_core/issues/21
module Piktur

  extend ::ActiveSupport::Autoload

  autoload :Cache, 'piktur/support/cache'
  autoload :Constants
  autoload :Container
  autoload :DEBUGGER, 'piktur/debugger'
  autoload :Deprecation
  autoload :Errors
  autoload :EventedFileUpdateChecker
  autoload :Loader
  autoload :Logger
  autoload :Plugin
  autoload :Plugins
  autoload :Reloader
  autoload :Registry
  autoload :Support
  autoload :Secrets
  autoload :Services

  require_relative './piktur/env.rb'
  require_relative './piktur/config.rb'

  # :nodoc
  module Interface

    # @param [Module] base
    #
    # @return [void]
    def self.extended(base)
      # Avoid explicit calls to `Piktur`, instead assign `base` to root scope and Use
      # this alias `NAMESPACE` to reference the dependent's namespace. 
      ::Object.const_set(:NAMESPACE, base)
    end
    
    # Returns absolute path to root directory
    #
    # @return [Pathname]
    def root; Pathname(__dir__).parent; end

    # @return [Piktur::Environment]
    def env; self::Environment.instance; end

    # @return [Config]
    def config; self::Config.config; end

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
    # @return [Services::Server]
    def servers; services.servers; end

    # @note Defaults to localhost if running dummy app
    #
    # @return [URI::Generic]
    def server
      if application.nil? || application.engine?
        servers.default
      else
        application.server.uri
      end
    end

    # @return [Array<Module>]
    def eager_load_namespaces; services.eager_load_namespaces; end

    # Returns the canonical file index for all loaded {.services}
    #
    # @return [Array<Services::FileIndex::Pathname>]
    def file_index; services.file_index.all; end

    include Support::Container::Delegates

    # @return [Dry::Container{String => Object}]
    def container; @container ||= self::Container.new; end

    # @return [Plugins::Registry]
    def plugins; @plugins ||= self::Plugins::Registry.new; end

    # @return [Logger]
    def logger; @logger ||= self::Logger.new; end

    # Set a conditional debugger entry point.
    # The debugger is triggered in debug mode only.
    #
    # @example Raise Exception after degugger session closed.
    #   begin
    #     do(something)
    #   rescue CriticalError => error
    #     ::NAMESPACE.debug(binding, true, error: error)
    #   end
    #
    # @example Log warning before debugger session opened.
    #   begin
    #     do(something)
    #   rescue TrivialError => error
    #     ::NAMESPACE.debug(binding, true, warning: error)
    #   end
    #
    # @param [Object] obj The Object to debug, typically a `Binding`.
    # @param [Object] diff
    # @param [Hash] options
    #
    # @option [String] options :warning
    # @option [String] options :error
    # @option [Symbol] options :throw
    # @option [Exception] options :raise
    #
    # @see Piktur::DEBUGGER
    #
    # @return [void]
    def debug(obj = binding, diff = true, warning: nil, error: nil, **options)
      const_get(:DEBUGGER)[obj, diff] unless env.production?

      if options[:raise]
        self::Errors.raise(options[:raise])
      elsif options[:throw]
        self::Errors.throw(options[:throw])
      elsif error
        self::Errors.error(error)
      elsif warning
        self::Errors.warn(warning)
      end
    end

  end
  private_constant :Interface

  extend Interface if ::File.basename(::Dir.pwd).start_with?('piktur')

  # @todo Implement production ready Secrets management.
  #   Use /bin/env in non-prouction enviroments to load ENV variables from **untracked**
  #   local files.
  # Secrets.overload

  # Install the optimised Inflector immediately
  Support.install(:object, :module, :inflector)

  # @param [Module] base
  #
  # @return [void]
  def self.extended(base)
    eager_load!

    base.extend Interface

    constants.each do |const|
      if const == :Config
        base.safe_const_set(:Config, ::Class.new(Config))
      else
        base.safe_const_set(const, const_get(const))
      end
    end
  end

end
