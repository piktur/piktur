# frozen_string_literal: true

module Piktur

  # @note The plugin:
  #   * CAN implement `.apply(klass, **options)`
  #   * or `.new(options)`
  #
  # @example
  #   module Piktur::Models
  #
  #     module Concerning
  #       module ClassMethods; end
  #
  #       module InstanceMethods; end
  #
  #       # apply the behaviour to the Class directly.
  #       def self.apply(klass, options = EMPTY_OPTS)
  #         klass.modify
  #       end
  #
  #       # or wrap dynamic methods within anononymous Module closure
  #       def self.new(base, options = EMPTY_OPTS)
  #         ::Module.new do
  #           define_method(:def_a) { }
  #           define_method(:def_b) { }
  #         end
  #       end
  #
  #       # or simply include this module
  #       def self.include(base)
  #         base.extend ClassMethods
  #         base.include InstanceMethods
  #       end
  #
  #     end
  #
  #     # Provides
  #     extend Support::Plugins
  #
  #     def self.install(klass, extensions)
  #
  #     end
  #   end
  #
  #   class Catalogue < ApplicationStruct
  #     extensions(self, <extension_name>: { option: :a, option: :b })
  #   end
  module Plugins

    extend ::ActiveSupport::Autoload

    autoload :Base
    autoload :Registry

    UnknownPluginError = ::Class.new(::StandardError)

    # :nodoc
    module Ext

      # @example
      #   module Users
      #     use :plugin_name, { key => value }
      #   end
      #
      # @param [Symbol] plugin
      # @param [Hash] options
      # @option options [Symbol]
      #
      # @return [void]
      def use(plugin, *args)
        ::Piktur.plugins.fetch(plugin).apply_to(self, *args)
      end

    end

  end

end
