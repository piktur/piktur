# frozen_string_literal: true

module Piktur

  module Support

    class Enum

      # @deprecated
      module Validator

        NonNumericValuerError = ::Class.new(::StandardError)

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
        #
        # @raise [ArgumentError] if value missing
        def validate!(key, value)
          # [REDUNDANT] It's not possible to define a duplicate key within a Hash
          # raise ::ArgumentError, DUPLICATE_KEY_MSG % { key: key } if
          #   duplicate_key?(key)

          # [REDUNDANT] Use the index of the Struct instance
          # raise ::ArgumentError, DUPLICATE_VALUE_MSG % { key: key, value: value } if
          #   duplicate_value?(value)

          # [REDUNDANT] The index is numeric
          # raise NonNumericValuerError, NON_NUMERIC_VALUE_MSG % { value: value } unless
          #   value.is_a?(Numeric)

          true
        end

        # @return [Boolean]
        def duplicate_key?(value); mapping.members.include?(value); end

        # @return [Boolean]
        def duplicate_value?(value); mapping.find { |_, obj| value == obj.value }; end

      end

    end

  end

end
