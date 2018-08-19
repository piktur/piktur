# frozen_string_literal: true

require 'dry-configurable'

module Piktur

  # Provides thread safe configuration.
  #
  # Store configuration for namespaces under `/config/piktur/*.rb`.
  # {Finalize.call} will {Finalize.finalize!} the given configuration files.
  class Config

    extend ::ActiveSupport::Autoload
    extend ::Dry::Configurable

    # @!attribute [rw] services
    #   @example
    #     Piktur::Config.configure do |config|
    #       config.services = %w(piktur_library piktur_engine piktur_application)
    #
    #       # With options
    #       config.services = %w(lib).push(component_types: [:models, :serializers])
    #     end
    #
    #   @see Piktur::Services
    #   @return [Services::Index]
    setting(:services, reader: true) do |services|
      options = services.pop if services && services[-1].is_a?(::Hash)
      Services::Index.new(services.map(&:to_s), options || EMPTY_HASH)
    end

    # Map noun forms to {Inflector} methods
    #
    # @return [Hash{Symbol=>Symbol}]
    FORMS = { singular: :singularize, plural: :pluralize }.freeze

    # @!attribute [rw] nouns
    #   @return [Pathname] the form in which {.component_types} will be referenced
    setting(:nouns, :plural) { |form| FORMS[form] || FORMS[:plural] }

    # @!attribute [rw] components_dir
    #   @return [Pathname] the relative path
    setting(:components_dir, 'app/concepts', reader: true) { |path| Pathname(path) }

    # @!attribute [rw] component_types
    #   @return [Pathname] a list of component types
    setting(:component_types, reader: true) do |types|
      types.map! { |e| ::Inflector.send(config.nouns, e).to_sym }
    end

    # @!attribute [rw] loader
    #   @see Piktur::Loader::Config
    #   @return [Dry::Configurable]
    setting(:loader, reader: true) do
      # @!attribute [rw] use_loader
      #   @return [Boolean]
      # setting(:use_loader, true, reader: true)
      setting(:instance, :active_support, reader: true) do |strategy|
        ::Piktur::Loader.build(strategy)
      end

      # @!attribute [rw] debug
      #   @return [Boolean]
      setting(:debug, ::ENV['DEBUG'], reader: true)
    end

    # :nodoc
    module Ext

      def [](name); config[name]; end

      def finalize!(freeze: ::NAMESPACE.env.production?)
        super() if freeze
      end

    end

    # Load namespaced configuration files under `config/<namespace>/**/*.rb`
    #
    # @example
    #   Finalize['site', 'store', 'blog', other: { scope: Object }]
    #   Finalize['site', freeze: ::NAMESPACE.env.production?]
    module Finalize

      class << self

        # @param [String] args A list of namespaces under `NAMESPACE`
        # @param [Hash] options Namespaced configuration and loading options
        #
        # @option options [Boolean] :freeze (false) in non-production environments
        #
        # @return [void]
        def call(*args, freeze: ::NAMESPACE.env.production?, **options)
          args.each { |mod| finalize!(mod, freeze: freeze) }
          options.each_pair { |mod, options| finalize!(mod, freeze: freeze, **options) } # rubocop:disable ShadowingOuterLocalVariable
        end
        alias [] call

        # @param [String] mod The namespace
        #
        # @option options [Module] :scope (`NAMESPACE`) The root namespace
        # @option options [Module] :root (`NAMESPACE.root`) The service root
        # @option options [Module] :dir (`NAMESPACE.to_s.downcase`) The relative path to the configuration
        #
        # @return [void]
        def finalize!(
          mod,
          scope: ::NAMESPACE,
          root:  ::NAMEPACE.root,
          dir:   ::NAMEPACE.to_s.downcase,
          **options
        )
          _load(mod, root: root, dir: dir)
          _finalize(mod, scope: scope, **options)
        end

        private

          # Evaluate file within anonymous module; variables will not be propagated globally.
          #
          # @raise [LoadError] if file not found
          #
          # @return [String]
          def _load(file, root:, dir:, **)
            file = ::File.join(root, 'config', *dir, "#{file}.rb")
            ::Kernel.load(file) if ::File.exist?(file)
          rescue ::NameError, ::LoadError => error
            ::Piktur.debug(binding, true, warning: error)
          end

          # @option see (#finalize!)
          #
          # @raise [NameError]
          #
          # @return [void]
          def _finalize(
            mod,
            scope: ::NAMESPACE,
            **options
          )
            mod = ::Inflector.camelize(mod)
            if scope.const_defined?(mod)
              scope.const_get(mod, false)
            elsif ::NAMESPACE.env.test? && ::Object.safe_const_get(:Test)&.const_defined?(mod)
              ::Test.const_get(mod, false)
            end.const_get(:Config, false).tap do |obj|
              obj.extend(Ext)
              obj.finalize!(options)
            end
          end

      end

    end

  end

end
