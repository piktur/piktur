# frozen_string_literal: true

module Piktur

  module Support

    # DRY common constant accessor patterns.
    #
    # @example Usage
    #   Support.install(:object)
    module Object

      # @return [void]
      def self.install(*)
        ::Object.include(self)
      end
      private_class_method :install

      # @param [Symbol, String] constant
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the named value
      # @return [nil] if constant undefined
      def safe_const_get(constant)
        return if constant.nil?
        const_get(constant, false) if const_defined?(constant, false)
      end

      # @param [Symbol, String] constant
      # @param [Object] value The new value
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the named value
      # @return [nil] if constant defined
      def safe_const_set(constant, value)
        return if constant.nil?
        const_set(constant, value) unless const_defined?(constant, false)
      end

      # @param [Symbol, String] constant
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the unnamed value
      # @return [nil] if constant undefined
      def safe_remove_const(constant)
        return if constant.nil?
        remove_const(constant) if const_defined?(constant, false)
      end

      # @param [Symbol, String] constant
      # @param [Object] value The value to assign if constant undefined
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the existing or given value
      def safe_const_get_or_set(constant, value = nil)
        return if constant.nil?
        safe_const_get(constant) || const_set(constant, block_given? ? yield : value)
      end

      # @param [Symbol, String] constant
      # @param [Object] value The new value
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the named value
      def safe_const_reset(constant, value = nil)
        return if constant.nil?
        safe_remove_const(constant)
        const_set(constant, block_given? ? yield : value)
      end

    end

  end

end
