# frozen_string_literal: true

module Piktur

  module Support

    # Preserve module heritage through inheritance chain.
    module Inheritable

      # Call `extension::Setup` on `extended` and ensure it is called again whenever `extended` is
      # included in another Module or Class.
      # @param [Module] extension
      # @param [Module, Class] extended
      # @return [void]
      def self.call(extension, extended)
        extension::Setup.(extended)

        return unless extended.is_a?(Module)

        extended.define_singleton_method(:included) do |base|
          extension::Setup.(base)
          super(base)
        end
      end
      private_class_method :call

      def extended(base)
        Inheritable.send(:call, self, base)
        super(base)
      end

    end

  end

end
