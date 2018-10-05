# frozen_string_literal: true

module Piktur

  module Support

    class Enum # rubocop:disable Documentation

      # @param [Symbol] name The collection name
      # @param [Hash] options
      #
      # @option options [Module] :namespace (Object) the parent module
      # @option options [Symbol] :predicates (nil) the enumerated attribute name
      # @option options [Symbol] :i18n_scope (nil)
      #
      # @return [Enum] an immutable Enum instance
      def self.new(name, namespace: ::Object, **options, &block)
        options, finisher = DSL.call(namespace, options, &block)

        super(name, options).finalize(namespace, options, &finisher)
      end

      def initialize(name, values:, i18n_scope:, **)
        @name = name.to_sym
        self.i18n_scope = i18n_scope

        build(values)

        default; key; to_s # memoize
      end

      # If given, yields self to block and adds `predicates` to the `namespace` if requested.
      #
      # @param [Module] namespace
      #
      # @option options [String, Symbol] :predicates
      #   Include {Predicates} for enumerated attribute
      # @option options [Boolean] :register
      #   Register the enum with the application {Interface#container}
      #
      # @yieldparam [self] enum The {Enum} instance
      #
      # @raise [RuntimeError]
      #
      # @return [self]
      def finalize(namespace, predicates: nil, register: false, **)
        raise(::RuntimeError, ENUM_FROZEN_MSG % inspect) if frozen?

        yield(self) if block_given?

        ::NAMESPACE.register(key, self) if register

        namespace.include(self.predicates(predicates)) if predicates

        freeze
      end

      DSL = ::Struct.new(:values, :options) do
        def self.call(namespace, options, &block)
          options[:i18n_scope] ||= namespace

          dsl = new({}, options).tap do |dsl| # rubocop:disable ShadowingOuterLocalVariable
            dsl.i18n_scope(namespace)
            dsl.instance_exec(&block)
          end

          args = [dsl.options.delete(:block)]
          args.unshift({ values: dsl.values }.update(dsl.options))
        end

        # Register the attribute to build predicates module for.
        #
        # @param [Symbol, String] attribute
        #
        # @return [void]
        def predicates(attribute)
          options[:predicates] = attribute
        end

        # Register the attribute to build scopes module for.
        #
        # @param [Symbol, String] attribute
        #
        # @return [void]
        def scopes(attribute)
          options[:scopes] = attribute
        end

        # @param [Symbol, String, Module] Use a scope other than the parent module name.
        #
        # @return [void]
        def i18n_scope(value)
          return if value == ::Object

          options[:i18n_scope] = case value
          when ::Module
            if value.respond_to?(:Name) then value.Name.i18n_key
            else Support::Inflector.underscore(value.to_s).to_sym
            end
          when ::String then value.to_sym
          when ::Symbol then value
          end
        end

        # Record intention to register Enum with the application container
        #
        # @return [void]
        def register
          options[:register] = true
        end

        # Block to extend the Enum instance.
        #
        # @yieldparam [Enum]
        #
        # @return [void]
        def finalize(&block)
          options[:block] = block
        end

        # @param [Symbol] key
        # @param [Hash] options
        #
        # @return [void]
        def default(key, **options)
          options[:default] = true
          values[key] = options
        end

        # @param [Symbol] key
        # @param [Hash] options
        #
        # @return [void]
        def value(key, **options)
          values[key] = options
        end
      end
      private_constant :DSL

    end

  end

end
