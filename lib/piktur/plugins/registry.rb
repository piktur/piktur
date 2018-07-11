# frozen_string_literal: true

module Piktur

  module Plugins

    # :nodoc
    class Registry < ::Piktur::Registry

      include ::Dry::Equalizer(:elements, :plugin_type)

      # @!attributre [rw] plugin_type
      #   @return [Class] Typically Piktur::Plugin or descendant
      attr_reader :plugin_type

      # @option options [Class] :plugin_type (Plugin)
      def initialize(*, plugin_type: Plugin, **)
        super
        @plugin_type = plugin_type
      end

      # Retrieve a registered plugin
      #
      # @param [Symbol] name The plugin to retrieve
      #
      # @return [Plugin]
      def [](name)
        elements[name]
      end

      # Register a plugin for future use
      #
      # @param [Symbol] name The name to register the plugin as
      # @param [Module] mod The plugin to register
      # @param [Hash] options
      #
      # @return [void]
      def register(name, mod, options = EMPTY_HASH)
        elements[name] = plugin_type.new(mod, options)
      end

    end

  end

end
