# frozen_string_literal: true

module Piktur

  module Support

    # Apply plugins to a given `klass`.
    #
    # @note The plugin:
    #   * **MUST** be defined within in the scope of this module
    #   * it **SHOULD** define a constant named `:Extension`
    #   * `<module>::Extension` must implement `install(klass, *args, **options)`
    #
    # @example
    #   module Piktur::Models
    #
    #     module Concerning
    #       module ClassMethods; end
    #
    #       module InstanceMethods; end
    #
    #       module Extension
    #         def self.install(klass, *args, **options)
    #           # add the behaviour to the Class.
    #         end
    #       end
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

      # @param [Module] klass The Module or Class to extend
      # @param [Hash{Symbol=>Hash}] extensions The extension name and relevant options
      #
      # @return [true]
      def install(klass, **extensions)
        extensions.each do |plugin, *args|
          # extension = ::Inflector.constantize("#{plugin}/extension", self, camelize: true)
          # throw(:abort) unless extension.respond_to?(:install, true)
          # extension.send(:install, klass, options)

          klass = ::Inflector.constantize(klass) unless klass.is_a?(::Module)
          send(extension, klass, *args)
        end
        true
      end

    end

  end

end
