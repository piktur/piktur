# frozen_string_literal: true

require 'dry-configurable'

module Piktur

  # Provides thread safe configuration.
  #
  # Store configuration for namespaces under `/config/piktur/*.rb`.
  # {Finalize.call} will {Finalize.finalize!} the given configuration files.
  class Config

    extend ::Piktur::Configurable

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
    setting :services, EMPTY_ARRAY, reader: true, &Types.Constructor(Services::Index) { |services|
      options = services.pop if services && services[-1].is_a?(::Hash)
      Services::Index.new(services.map(&:to_s), *options)
    }
      .meta(reader: true)
      .default { |type| type[EMPTY_ARRAY] }
      .method(:call)

    # Map noun forms to {Inflector} methods
    #
    # @return [Hash{Symbol=>Symbol}]
    FORMS = { singular: :singularize, plural: :pluralize }.freeze

    # @!attribute [rw] nouns
    #   @return [Symbol] the form in which {.component_types} will be referenced
    setting :nouns, :plural, reader: true, &Types['symbol']
      .constructor { |input| FORMS[input] || FORMS[:plural] }
      .meta(reader: true)
      .default(:plural)
      .method(:call)

    # @!attribute [rw] components_dir
    #   @return [Pathname] the relative path
    setting :components_dir, 'app/concepts', reader: true, &Types.Constructor(Pathname)
      .meta(reader: true)
      .default { |type| type['app/concepts'] }
      .method(:call)

    # @!attribute [rw] component_types
    #   @return [Array<Symbol>] a list of component types
    setting :component_types, EMPTY_ARRAY, reader: true, &Types['array']
      .constructor { |input| input.map { |e| ::Inflector.send(config.nouns, e).to_sym } }
      .meta(reader: true)
      .default { |type| type[EMPTY_ARRAY] }
      .method(:call)

    # @!attribute [rw] loader
    #   @see Piktur::Loader::Config
    #   @return [Dry::Configurable]
    setting :loader, reader: true do
      # @!attribute [rw] use_loader
      #   @return [Boolean]
      # setting(:use_loader, true, reader: true)
      setting :instance, :active_support, reader: true, &Types.Constructor(Loader) { |strategy|
        strategy.is_a?(::Symbol) ? Loader.build(strategy) : strategy
      }
        .meta(reader: true)
        .default { |type| type[:active_support] }
        .method(:call)

      # @!attribute [rw] debug
      #   @return [Boolean]
      setting :debug, ::ENV['DEBUG'], reader: true, &Types['params.bool']
        .meta(reader: true)
        .default { ::ENV['DEBUG'].present? }
        .method(:call)
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
          root: ::NAMESPACE.root.join('config'),
          dir: ::NAMESPACE.to_s.downcase,
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
            file = ::Dir[::File.join(root, *dir, "{#{file},config}.rb")][0]
            ::Kernel.load(file) if file && ::File.exist?(file)
          rescue ::NameError, ::LoadError => err
            ::Piktur.debug(binding, true, raise: err)
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
