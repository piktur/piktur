# frozen_string_literal: true

# rubocop:disable ParallelAssignment, Delegate, SymbolProc, DynamicFindBy, FormatString

require 'dry-struct'
require 'dry-types'

module Piktur

  module Support

    # Enum maps static values and human readable translations to a developer friendly identifier.
    class Enum

      # Immutable object provides consistent representation of an enumerated value.
      class Value < Dry::Struct

        constructor_type :schema

        attribute :key,        Dry::Types['symbol']
        attribute :value,      Dry::Types['any']
        attribute :default,    Dry::Types['bool'].default(false)
        attribute :i18n_scope, Dry::Types['array']

        def ==(other); value == other; end

        def human(**options); ::I18n.t(key, scope: i18n_scope, **options); end

        def to_s; human; end

      end

      # @example
      #   class Genders < Enum
      #     enum  name: :genders,
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

        DUPLICATE_KEY_MSG = <<~EOS
          Key %{key} is already defined.
        EOS

        DUPLICATE_VALUE_MSG = <<~EOS
          Value %{value} is already defined. You must provide a unique value for %{key}.
        EOS

        NOT_FOUND_MSG = <<~EOS
          %{enum} does not include %{value}.
        EOS

        attr_accessor :mapping, :keys, :values, :predicates

        def enum(name:, predicates: true, **enumerated)
          @name, @mapping = name.to_sym, {}
          enumerated.each { |key, options| declare(key, options) }
          @keys, @values = mapping.keys.freeze, mapping.values.freeze
          @mapping.freeze
        end

        def declare(key, value:, **options)
          validate!((key = key.to_sym), value)
          options[:i18n_scope] = i18n_scope
          mapping[key] = Value.new(key: key, value: value, **options)
          define_method(key) { mapping[key] }
        end

        def find(value); find_by_key(value) || find_by_value(value); end

        def find!(value); find(value) || not_found!(value); end
        alias [] find!

        def find_by_key(value); values.find { |obj| obj.key == value }; end

        def find_by_key!(value); find_by_key(value) || not_found!(value); end

        def find_by_value(value); values.find { |obj| obj.value == value }; end

        def find_by_value!(value); find_by_value(value) || not_found!(value); end

        def include?(value); find(value).present?; end

        def default; @default ||= values.find { |e| e.default }; end

        def size; values.size; end

        def each(&block); mapping.each(&block); end

        def to_enum; mapping.enum_for; end

        alias to_a values

        def i18n_scope; @i18n_scope ||= ['enums', parent_name.underscore, @name]; end

        def predicates(attribute); Predicates[attribute, self]; end

        private

          def not_found!
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
