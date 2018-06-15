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
      # @param [Module] namespace Scope constant lookup
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the named value
      # @return [nil] if constant undefined
      def safe_const_get(constant, namespace = ::Object)
        return if constant.nil?
        namespace.const_get(constant) if namespace.const_defined?(constant)
      end

      # @param [Symbol, String] constant
      # @param [Object] value The new value
      # @param [Module] namespace Scope constant lookup
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the named value
      def safe_const_set(constant, value, namespace = ::Object)
        return if constant.nil?
        namespace.const_set(constant, value) unless namespace.const_defined?(constant)
      end

      # @param [Symbol, String] constant
      # @param [Module] namespace Scope constant lookup
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the unnamed value
      def safe_remove_const(constant, namespace = ::Object)
        return if constant.nil?
        namespace.send(:remove_const, constant) if namespace.const_defined?(constant)
      end

      # @param [Symbol, String] constant
      # @param [Object] value The new value
      # @param [Module] namespace Scope constant lookup
      #
      # @raise [NameError] if `constant` invalid
      #
      # @return [Object] the named value
      def safe_const_reset(constant, value = nil, namespace = ::Object)
        return if constant.nil?
        ::Object.safe_remove_const(constant, namespace)
        ::Object.safe_const_set(constant, value, namespace)
      end

    end

  end

end
