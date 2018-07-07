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
        @type = options.fetch(:type)
      end

      # Apply this plugin to the provided class
      #
      # @param [Module] base
      #
      # @return [void]
      def apply_to(*)
        raise NotImplementedError, "#{self.class}#apply_to not implemented"
      end

    end

  end

end
