# frozen_string_literal: true

module Piktur

  module Support

    # Preserve module heritage through inheritance chain.
    module Inheritable

      class << self

        # @param [Module] base
        # @return [void]
        def extended(base)
          base.extend Inheritable::ClassMethods
        end

        # Return all Classes in inheritance chain
        #
        # @param [Class] klass
        # @yieldparam [Class] superclass
        #
        # @return [Array<Class>]
        def inheritance_chain(klass, &block)
          ancestry = [klass]
          ancestry << (klass = klass.superclass) until klass.superclass == ::Object
          block ? ancestry.each(&block) : ancestry
        end

        # @param [Method]
        #
        # @return [Array<Object, Method>]
        def super_method_chain(method)
          chain = [method]
          chain << method while (method = method.super_method)
          chain
        end

        private

          # Call `extension::Setup` on `extended` and ensure it is called again whenever
          # `extended` is included in another Module or Class.
          #
          # @param [Module] extension
          # @param [Module, Class] extended
          #
          # @return [void]
          def call(extension, extended)
            extension::Setup.(extended)

            return unless extended.is_a?(Module)

            extended.define_singleton_method(:included) do |base|
              extension::Setup.(base)
              super(base)
            end
          end

      end

      module Ext

        def extended(base)
          Inheritable.send(:call, self, base)
          super(base)
        end

      end

      # :nodoc
      module ClassMethods

        # @see Piktur::Support::Inheritable.inheritance_chain
        #
        # @return [Array<Class>]
        def inheritance_chain(&block)
          Inheritable.inheritance_chain(self, &block)
        end

        # @param [Method] method
        #
        # @see Piktur::Support::Inheritable.inheritance_chain
        #
        # @return [Array<Method>]
        def super_method_chain(method, &block)
          method = self.method(method) unless method.is_a?(Method)
          Inheritable.super_method_chain(method, &block)
        end

      end

    end

  end

end
