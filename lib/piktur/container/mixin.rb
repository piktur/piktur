# frozen_string_literal: true

module Piktur::Container # rubocop:disable ClassAndModuleChildren

  module Mixin # rubocop:disable Documentation

    # @return [__container__.main]
    def container; ::NAMESPACE.__container__.main; end

    # @return [__container__.operations]
    def operations; ::NAMESPACE.__container__.operations; end

    # @return [__container__.types]
    def types; ::NAMESPACE.__container__.types; end

    # @example
    #   Things.component(:validator)             # => <Things::Validator>
    #   Things.component(:validators, 'variant') # => <Things::Validators::Variant>
    #
    # @param [String, Symbol] component_type One of {Piktur::Config.component_types}
    # @param [String, Symbol] variant The variant name
    #
    # @see file:benchmark/string_manipulation.rb
    #
    # @raise [Dry::Container::Error] if item not registered
    #
    # @return [Object] the container item registered as key
    def component(namespace, component_type, variant = nil)
      container[container.to_key([namespace, component_type, *variant])]
    end

    # @param (#component)
    #
    # @return [Object]
    def variant(namespace, component_type, variant = __variant__)
      container[container.to_key([namespace, component_type, variant])]
    end

    # @param (#component)
    #
    # @return [Piktur::Operation]
    def operation(namespace, *args)
      operations[operations.to_key([namespace, *args])]
    end
    alias transaction operation

    # @return [Dry::Types::Constructor]
    def schema(namespace)
      types[types.to_key([namespace, __callee__])]
    end
    alias struct schema

    private

      # @!attribute [rw] __variant__
      #   @return [String]
      attr_writer :__variant__

      def __variant__
        @__variant__ ||= ::Piktur::Concepts::Naming::DEFAULT_VARIANT # rubocop:disable MemoizedInstanceVariableName
      end

  end

end
