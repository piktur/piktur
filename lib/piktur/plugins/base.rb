# frozen_string_literal: true

# require 'rom/plugin_base'

module Piktur

  module Plugins

    # Base = ::ROM::PluginBase

    # @abstract
    #
    # @see https://github.com/rom-rb/blob/master/rom/core/lib/rom/plugin_base.rb
    module Base

      # @return [Module] a module representing the plugin
      attr_reader :mod

      # @return [Hash] configuration options
      attr_reader :options

      # @return [Hash] configuration options
      attr_reader :type

      def initialize(mod, options)
        @mod = mod
        @options = options
        @type = options.fetch(:type) { :default }
      end

      # Apply this plugin to the provided class
      #
      # @param [Class] klass The component definition
      # @param [Array<Object>] args
      #
      # @return [void]
      def apply_to(klass, *args)
        if mod.respond_to?(:apply)
          mod.apply(klass, *args)
        elsif mod.respond_to?(:new)
          # Wrap dynamic methods in anonymous module closure; include
          klass.send(:include, mod.new(*args))
        else
          # Include static module
          klass.send(:include, mod)
        end
      end

    end

  end

end
