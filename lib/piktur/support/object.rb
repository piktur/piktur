# frozen_string_literal: true

# rubocop:disable RedundantSelf

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
        self.const_get(constant, false) if self.const_defined?(constant, false)
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
        self.const_set(constant, value) unless self.const_defined?(constant, false)
      end

      # @param [Symbol, String] constant
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the unnamed value
      # @return [nil] if constant undefined
      def safe_remove_const(constant)
        return if constant.nil?
        self.send(:remove_const, constant) if self.const_defined?(constant, false)
      end

      # @param [Symbol, String] constant
      # @param [Object] value The value to assign if constant undefined
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the existing or given value
      def safe_const_get_or_set(constant, value = nil)
        return if constant.nil?
        self.safe_const_get(constant) || self.const_set(constant, block_given? ? yield : value)
      end

      # @param [Symbol, String] constant
      # @param [Object] value The new value
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the named value
      def safe_const_reset(constant, value = nil)
        return if constant.nil?
        self.safe_remove_const(constant)
        self.const_set(constant, block_given? ? yield : value)
      end

    end

  end

end
