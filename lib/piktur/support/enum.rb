# frozen_string_literal: true

# rubocop:disable ParallelAssignment, Delegate, SymbolProc, DynamicFindBy, FormatString, Documentation

require 'dry-struct'
require 'dry-types'

module Piktur

  module Support

    # Enum maps static values and translation to a developer friendly identifier.
    class Enum

      # Immutable object provides consistent representation of an enumerated value.
      #
      # @!attribute [r] key
      #   @return [Symbol]
      # @!attribute [r] value
      #   @return [Object]
      # @!attribute [r] default
      #   @return [Boolean]
      # @!attribute [r] i18n_scope
      #   @return [Array<Symbol>]
      class Value

        attr_reader :key, :value, :default, :i18n_scope

        def initialize(key:, value:, i18n_scope:, default: false)
          @key        = key.to_sym
          @value      = value
          @default    = default
          @i18n_scope = i18n_scope
          freeze
        end

        # @param [Hash] options
        # @return [String]
        def human(**options); ::I18n.t(@key, scope: i18n_scope, **options); end

        # @return [String]
        def to_s; human; end

        # @return [Boolean]
        def ==(other); value == other; end

      end

      # @example
      #   class Genders < Enum
      #     enum  :genders,
      #           nil:        { value: 0, default: true },
      #           male:       { value: 1 },
      #           female:     { value: 2 },
      #           non_binary: { value: 3 }
      #   end
      #
      #   Genders[0]    # => <Piktur::Support::Enum::Value key=:key value=0>
      #
      #   Genders[:key] # => <Piktur::Support::Enum::Value key=:key value=0>
      #
      class << self

        I18N_NAMESPACE = :enums

        DUPLICATE_KEY_MSG = <<~EOS
          Key %{key} already defined.
        EOS

        DUPLICATE_VALUE_MSG = <<~EOS
          Value %{value} already defined. Provide a unique value for "%{key}".
        EOS

        NOT_FOUND_MSG = <<~EOS
          Value "%{value}" not in %{enum}.
        EOS

        attr_accessor :mapping, :keys, :values

        # @param [Symbol] name
        # @param [Boolean] predicates
        # @param [Hash] enumerated
        # @return [void]
        def enum(name, predicates: true, **enumerated)
          @name, @mapping = name.to_sym, {}
          @i18n_scope     = [I18N_NAMESPACE, parent_name.underscore.to_sym, @name]
          enumerated.each { |key, options| declare!(key, i18n_scope: @i18n_scope, **options) }
          @keys, @values = mapping.keys.freeze, mapping.values.freeze
          @mapping.freeze
          true
        end

        # @return [Enum::Value]
        def find(value); find_by_key(value) || find_by_value(value); end

        # @raise [ArgumentError]
        # @return [Enum::Value]
        def find!(value); find(value) || not_found!(value); end
        alias [] find!

        # @return [Enum::Value]
        def find_by_key(value); values.find { |obj| obj.key == value }; end

        # @return [Enum::Value]
        def find_by_key!(value); find_by_key(value) || not_found!(value); end

        # @return [Enum::Value]
        def find_by_value(value); values.find { |obj| obj.value == value }; end

        # @return [Enum::Value]
        def find_by_value!(value); find_by_value(value) || not_found!(value); end

        def include?(value); find(value).present?; end

        # @return [Enum::Value]
        def default; @default ||= values.find { |e| e.default }; end

        # @return [Integer]
        def size; values.size; end

        # @return [Array]
        def each(&block); mapping.each(&block); end

        # @return [Array]
        def select(&block); mapping.select(&block); end

        # @return [Enumerator]
        def to_enum; mapping.enum_for; end

        def to_hash; mapping.map { |k, v| v.value }; end

        alias to_h to_hash
        alias to_a values

        # @return [Module]
        def predicates(attribute); Predicates[attribute, self]; end

        private

          # * Store {Value} under `key`
          # * Define scoped `I18n` helper
          # * Define method for `key`
          # @return [void]
          def declare!(key, value:, **options)
            validate!((key = key.to_sym), value)
            mapping[key] = Value.new(key: key, value: value, **options)
            define_singleton_method(key) { mapping[key].value }
          end

          def not_found!(value)
            raise ArgumentError, NOT_FOUND_MSG % { value: value, enum: @name }
          end

          def validate!(key, value)
            raise ArgumentError, DUPLICATE_KEY_MSG % { key: key } if
              duplicate_key?(key)
            raise ArgumentError, DUPLICATE_VALUE_MSG % { key: key, value: value } if
              duplicate_value?(value)
            true
          end

          def duplicate_key?(value); mapping.key?(value); end

          def duplicate_value?(value); mapping.find { |_, obj| value == obj.value }; end

      end

      module Predicates

        class << self

          def call(attribute, enum)
            Module.new do
              enum.each do |key, obj|
                define_method("#{key}?") { enum.include? send(attribute) }
                define_method("#{key}!") { send "#{attribute}=", enum[key].value }
              end
            end
          end
          alias [] call

        end

      end

    end

  end

end
