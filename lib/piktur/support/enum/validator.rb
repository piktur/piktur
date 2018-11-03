# frozen_string_literal: true

module Piktur::Support # rubocop:disable ClassAndModuleChildren

  module Enum

    class Validator

      DUPLICATE_KEY_MSG = <<~MSG
        Key %{key} already defined.
      MSG

      DUPLICATE_VALUE_MSG = <<~MSG
        Value %{value} already defined. Provide a unique value for "%{key}".
      MSG

      NAME_COLLISION_MSG = <<~MSG
        Name Collision: method "%{m}" is already defined. %{file}:%{line}
      MSG

      NON_NUMERIC_VALUE_MSG = <<~MSG
        Value %{value} MUST BE numeric.
      MSG

      # @param [Symbol] key
      # @param [Numeric] value
      # @param [Hash] mapping
      #
      # @return [true] if valid
      def call(key, value, mapping)
        result = catch :invalid do
          return [
            unique_key?(key, mapping),
            unique_value?(key, value, mapping),
            type?(value)
          ].all?
        end

        throw :invalid, result
      end

      private

        def unique_key?(key, mapping)
          if mapping.key?(key)
            throw :invalid, format(DUPLICATE_KEY_MSG, key: key)
          else
            true
          end
        end

        def unique_value?(key, value, mapping)
          if mapping.find { |_, obj| obj.value == value }
            throw :invalid, format(DUPLICATE_VALUE_MSG, key: key, value: value)
          else
            true
          end
        end

        def type?(value)
          if value.is_a?(::Numeric)
            true
          else
            throw :invalid, format(NON_NUMERIC_VALUE_MSG, value: value)
          end
        end

    end

  end

end
