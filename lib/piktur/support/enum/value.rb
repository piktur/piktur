# frozen_string_literal: true

module Piktur

  module Support

    class Enum

      # Immutable object provides consistent representation of an enumerated value.
      class Value

        # @!attribute [r] key
        #   @return [Symbol]
        attr_reader :key

        # @!attribute [r] value
        #   @return [Object]
        attr_reader :value

        # @!attribute [r] matcher
        #   @return [Regexp]
        attr_reader :matcher

        # @!attribute [r] default
        #   @return [Boolean]
        attr_reader :default
        alias default? default

        # @!attribute [r] i18n_scope
        #   @return [Array<Symbol>]
        attr_reader :i18n_scope

        # @!attribute [r] meta
        #   @return [Hash, nil]
        attr_reader :meta

        def initialize(key:, value:, i18n_scope:, default: false, meta: nil)
          @key        = key.to_sym
          @value      = value
          @default    = default
          @matcher    = /\A#{key}\Z/
          @i18n_scope = i18n_scope
          @meta       = meta&.freeze
          freeze
        end

        # @return [Integer]
        def as_json(**); value; end

        # @param [Hash] options
        #
        # @return [String]
        def human(**options); ::I18n.t(@key, scope: i18n_scope, **options); end

        # @return [String] the camelized constant name
        def camelize
          Support::Inflector.camelize(to_s)
        end

        # @return [String]
        def to_s; key.to_s; end

        # @return [Symbol]
        def to_sym; key; end

        # @return [Integer]
        def to_i; value; end

        # @example
        #   ::Piktur::Types.Enum(Object, :colours, red: { value: 0 }, green: { value: 1 })
        #   Colours[:red] == Colours[:red] # => true
        #   Colours[:red] == 'red'         # => true
        #   Colours[:red] == :red          # => true
        #   Colours[:red] == :green        # => false
        #   Colours[:red] == 0             # => true
        #   Colours[:red] == 1             # => false
        #
        # @return [Boolean]
        def eql?(other)
          return super if other.is_a?(Value)
          return false if defined?(Undefined) && other == Undefined

          (value == other) || (key == other) || match?(other)
        end
        alias == eql?

        # @example
        #   gender = :male
        #
        #   case gender
        #   when Genders[:male]   then 'blue'
        #   when Genders[:female] then 'red'
        #   else 'black'
        #   end
        #
        # @return [Boolean]
        def ===(other)
          return self == other if other.is_a?(Value)
          (value == other) || (key == other)
        end

        # @example
        #   Enum[Object, :colours, red: { value: 0 }, green: { value: 1 }]
        #   Colours[:red] =~ 'red'  # => true
        #   Colours[:red] == :red   # => true
        #   Colours[:red] == 0      # => false
        #
        # @return [Boolean]
        def match?(other)
          return false unless other.respond_to?(:match?)
          other.match?(matcher)
        end
        alias =~ match?

        # @return [String]
        def inspect
          "<Enum::Value #{key}=#{value} default=#{@default}>"
        end

      end

    end

  end

end
