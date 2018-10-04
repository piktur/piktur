# frozen_string_literal: true

require 'pathname'
%w(
  dependencies/autoload
  core_ext/string/inquiry
  core_ext/object/blank
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
  autoload :Configurable
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

  # @note You should really restart Spring before switching environments.
  defined?(::Spring) && ::Spring.after_fork do
    # Reset singleton Environment instance.
    safe_remove_const(:Environment)
    ::Kernel.load(::File.expand_path('./piktur/env.rb', __dir__))

    NAMESPACE.remove_instance_variable(:@logger)
  end

  require_relative './piktur/env.rb'

  # :nodoc
  module Interface

    include Support::Container::Delegates

    # Avoid explicit calls to `Piktur`, instead assign `base` to root scope and Use
    # this alias `NAMESPACE` to reference the dependent's namespace.
    #
    # @param [Module]
    #
    # @return [void]
    def self.extended(base)
      ::Object.const_set(:NAMESPACE, base)
      Support.install(:types)

      require_relative './piktur/config.rb'
    end

    # @return [void]
    def setup!
      return unless ENV['DISABLE_SPRING']

      ::Bundler.require(:default, :test, :benchmark)
    end

    # @return [void]
    def boot!(*)
      true
    end

    # Returns absolute path to root directory
    #
    # @return [Pathname]
    def root; Pathname(__dir__).parent; end

    # @return [Environment]
    def env; self::Environment.instance; end

    # @return [void]
    def configure(&block); self::Config.configure(&block); end

    # @return [Config]
    def config; self::Config.config; end

    # @return [Services::Index]
    def services; @services ||= Services::Index.new; end

    # Returns Service object for current application
    #
    # @return [Services::Service]
    def application; services.application; end

    # Predicate checks existence of Rails application singleton. Use when opting out of operations
    # that will be handled by the Rails boot.
    #
    # @return [Boolean]
    def rails?
      defined?(::Rails) && ::Rails.application.present? # &.initialized?
    end

    # @return [Boolean]
    def initialized?
      rails? && ::Rails.application.initialized?
    end

    # @return [Boolean]
    def rake?
      defined?(::Rake) && ::Rake.application.present?
    end

    # The predicate may be used to limit loading when booting the test environment.
    #
    # @see file:bin/env
    #
    # @return [Boolean]
    def rspec?; ::ENV['TEST_RUNNER'].present?; end

    # Predicate checks Rails application singleton is an instance of the dummy application.
    #
    # @return [Boolean]
    def dummy?
      defined?(::Piktur::Spec::Application) &&
        ::Rails.application.is_a?(::Piktur::Spec::Application)
    end

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

    # @example
    #   components_dir(::Rails.root) # => <Pathname:/root/app/concepts>
    #   components_dir               # => <Pathname:app/concepts>
    #
    # @see Config.components_dir
    #
    # @param [Pathname] root
    #
    # @return [Pathname] the relative path of the components directory
    # @return [Pathname] if `root` the absolute path of the components directory from root
    def components_dir(root = nil)
      root ? config.components_dir.expand_path(root) : config.components_dir
    end

    # @see Config.component_types
    #
    # @return [Array<Symbol>] A list of the component types implemented
    def component_types; config.component_types; end

    # @return [Dry::Container{String => Object}]
    def container; @container ||= self::Container.new; end

    # @!attribute [rw] types
    #   @return [Dry::Container{String => Object}]
    def types; Types.container end
    def types=(container); Types.container = container; end

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
    #   rescue CriticalError => err
    #     ::NAMESPACE.debug(binding, true, error: err)
    #   end
    #
    # @example Log warning before debugger session opened.
    #   begin
    #     do(something)
    #   rescue TrivialError => err
    #     ::NAMESPACE.debug(binding, true, warning: err)
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
    # @see DEBUGGER
    #
    # @return [void]
    def debug(obj = binding, diff = true, warning: nil, error: nil, **options) # rubocop:disable MethodLength
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

      nil
    end

  end
  private_constant :Interface

  Constants.install
  Support.install(:inflector)
  require_relative './piktur/support/container.rb'

  extend Interface if File.basename(Dir.pwd).start_with?('piktur')

  # @todo Implement production ready Secrets management.
  #   Use /bin/env in non-prouction enviroments to load ENV variables from **untracked**
  #   local files.
  # Secrets.overload

  # @param [Module] base
  # @param [Array<Symbol, String>] args A list of constants to be aliased
  #
  # @return [void]
  def self.install(base, *args, containerize: false) # rubocop:disable MethodLength
    base.extend Interface

    eager_load!

    ::Set[
      :Support,
      :Environment,
      :Deprecation,
      :DEBUGGER,
      :Errors,
      :Logger,
      :Config,
      *args.map(&:capitalize)
    ].each do |const|
      if const == :Config
        base.safe_const_set(:Config, ::Class.new(Config))
      else
        base.safe_const_set(const, const_get(const))
      end
    end

    base.include Constants
    base.extend Support::Container::Mixin if containerize
  end

end
