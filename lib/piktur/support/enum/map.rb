# frozen_string_literal: true

module Piktur::Support # rubocop:disable ClassAndModuleChildren

  module Enum

    # Wraps underlying `Hash` mapping Symbol => Numeric
    class Map < Set

      # @param [Symbol, Numeric, Value] input
      #
      # @raise [ArgumentError]
      #
      # @return [Enum::Value]
      def find!(input)
        return input if input.is_a?(Value)

        mapping.fetch(input) { find_by_value!(input) }
      end

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def each(&block); values.each(&block); end

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def select(&block); values.select(&block); end

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def map(&block); values.map(&block); end

      # @param [Array<Symbol>] args
      #
      # @return [Array<Value>]
      def values_at(*args)
        mapping.values_at(*args)
      end

      # @return [Enum::Value]
      # @return [nil] if default value not set
      def default
        return @default if defined?(@default) # @default may be nil

        @default = values.find(&:default?)
      end

      private def build(enumerable)
        @mapping = {}

        enumerable.each.with_index do |(key, options), i|
          Enum.validator.call((key = key.to_sym), options[:value] ||= i, @mapping)

          value = add(key, i18n_scope: @i18n_scope, enum: self, **options)
          @mapping[key] = value
        end

        @keys = @mapping.keys.freeze
        @values = @mapping.values.freeze
        @mapping.freeze
      end

    end

  end

end
