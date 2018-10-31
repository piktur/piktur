# frozen_string_literal: true

# rubocop:disable ClassAndModuleChildren

class Piktur::Support::Enum

  # :nodoc
  module Plugins

    extend ::ActiveSupport::Autoload

    autoload :Types

    PLUGINS = {
      types: :Types
    }.freeze
    private_constant :PLUGINS

    # @param [Symbol] The plugin name
    #
    # @return [void]
    def use(plugin)
      include Plugins.const_get(PLUGINS[plugin], false)
    end

  end

end
