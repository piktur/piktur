# frozen_string_literal: true

module Piktur::Support # rubocop:disable ClassAndModuleChildren

  module Enum

    # Wraps underlying `Struct` mapping Symbol => Numeric
    class Set

      include Constructor

      # @!attribute [r] name
      #   @return [Symbol]
      attr_reader :name

      # @!attribute [r] mapping
      #   @return [Struct]
      attr_reader :mapping

      # @!attribute [r] keys
      #   @return [Array<Symbol>]
      attr_reader :keys

      # @!attribute [r] values
      #   @return [Array<Value>]
      attr_reader :values

      # @!attribute [rw] i18n_scope
      #   @return [Array<Symbol>]
      attr_reader :i18n_scope

      # @param [String, Symbol]
      #
      # @return [Array<Symbol>]
      def i18n_scope=(namespace)
        @i18n_scope = [Enum.i18n_namespace, *namespace, name].freeze
      end

      # @param [Symbol, String, Integer] input
      #
      # @return [Value]
      def call(input)
        find(input) || default
      end

      # @!group Queries

      # @!method find_by_key
      # @!method find_by_value
      #
      # @param [String, Symbol, Integer, Value] input
      #
      # @return [Value, nil]
      def find(input)
        return input if input.is_a?(Value)

        values.find { |value| value == input }
      end
      alias [] find

      # @raise [IndexError] if value out of range
      # @raise [NameError] if key missing
      #
      # @return [Value] if `input` in `mapping.members` or `mapping.values`
      def find!(input)
        return input if input.is_a?(Value)

        mapping[input]
      end

      def find_by_key(input); values.find { |value| value.key == input }; end

      def find_by_value(input); values.find { |value| value.value == input }; end

      # @!method []
      # @!method find!
      # @!method find_by_key!
      # @!method find_by_value!
      # @param [Object] value
      # @raise [ArgumentError]
      # @return [Enum::Value]

      def find_by_key!(input); find_by_key(input) || not_found!(input); end

      def find_by_value!(input); find_by_value(input) || not_found!(input); end

      # @return [Boolean]
      def include?(value); find(value).present?; end

      # @return [Enum::Value]
      # @return [nil] if default value not set
      def default
        return @default if defined?(@default) # @default may be nil

        @default = mapping.find(&:default?)
      end

      # @return [Integer]
      # @return [nil] if default value not set
      def default_value; default&.value; end

      # @!endgroup

      # @!group Enumeration

      # @return [Integer] the number of enumerated values
      def size; mapping.size; end
      alias length size

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def each(&block); mapping.each(&block); end

      # @yieldparam [Symbol] key
      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def each_pair(&block); mapping.each_pair(&block); end

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def select(&block); mapping.select(&block); end

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def map(&block); mapping.map(&block); end

      # @param [Array<Integer>] args
      #
      # @return [Array<Value>]
      def values_at(*args)
        mapping.values_at(*args)
      rescue ::IndexError
        EMPTY_ARRAY
      end

      # @return [Enumerator]
      def to_enum; mapping.enum_for; end

      # @!method to_a
      #   @return [Array<Enum::Value>]
      alias to_a values

      # @param [Array] other
      #
      # @return [Array<Enum::Value>]
      def &(other); values & other; end

      # @!endgroup

      # @return [String]
      def human(*); Enum.inflector.humanize(name); end

      # @return [String]
      def to_s; name.to_s; end

      # @return [String]
      def key; @key ||= Enum.container.to_key(i18n_scope).freeze; end

      # @return [Hash]
      def to_hash; h = {}; each { |v| h[v.key] = v.value }; h; end
      alias to_h to_hash

      # @param [String, Symbol] attribute
      #
      # @return [Module]
      def predicates(attribute); Predicates[attribute, self]; end

      # @param [String, Symbol] attribute
      #
      # @return [Module]
      def attributes(attribute); Attributes[attribute, self]; end

      # @return [String]
      def inspect
        "<Enum[#{key}] #{map { |val| "#{val.key}=#{val.to_i}" }.join(' ')}>"
      end

      private

        # @return [true] if {#key} include the method name
        def respond_to_missing?(method_name, include_private = false)
          keys.include?(method_name) || super
        end

        # Forwards the method call to {#mapping}
        #
        # @raise [NoMethodError]
        # @return [void]
        def method_missing(method_name, *args)
          respond_to_missing?(method_name) && mapping.send(method_name) || super
        end

        # @param [Numeric] value
        #
        # @raise [ArgumentError] if value missing
        def not_found!(value)
          raise ::ArgumentError, format(NOT_FOUND_MSG, value: value, enum: name)
        end

    end

  end

end
