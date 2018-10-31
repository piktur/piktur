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
      # @option options [String, Symbol] :attributes
      #   Include {Attributes} for enumerated attribute
      # @option options [Boolean] :register
      #   Register the enum with the application {Interface#container}
      #
      # @yieldparam [self] enum The {Enum} instance
      #
      # @raise [RuntimeError]
      #
      # @return [self]
      def finalize(namespace, predicates: nil, attributes: nil, register: false, **)
        raise(::RuntimeError, ENUM_FROZEN_MSG % inspect) if frozen?

        yield(self) if block_given?

        self.register if register

        namespace.include(self.predicates(predicates)) if predicates

        namespace.include(self.attributes(attributes)) if attributes

        values.each(&:freeze)
        freeze
      end

      def register
        return if Enum.container.nil?

        Enum.container.register(key, self)
      end

      # Build {Value} for each in `enumerable` collection.
      #
      # @param [Hash] enumerable
      #
      # @return [void]
      private def build(enumerable)
        @mapping = ::Struct.new(*enumerable.keys).allocate

        enumerable.each.with_index do |(key, options), i|
          options[:value] = i
          value = declare!(key, i18n_scope: @i18n_scope, enum: self, **options)
          @mapping[key] = value
        end

        @keys   = @mapping.members.freeze
        @values = @mapping.values.freeze
        @mapping.freeze
      end

      # * Store {Value} under `key`
      # * Define scoped `I18n` helper
      # * Define method for `key`
      #
      # @return [void]
      private def declare!(key, value: nil, **options)
        # validate!((key = key.to_sym), value)
        Value.new(key: key, value: value, **options)
      end

    end

  end

end
