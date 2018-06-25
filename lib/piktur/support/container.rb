# frozen_string_literal: true

require 'dry/container'
require 'dry/monads'

module Piktur

  module Support

    # :nodoc
    module Container

      extend ::ActiveSupport::Autoload

      autoload :Delegates, 'piktur/support/container'

      # @return [String]
      NAMESPACE_SEPARATOR = '.'

      # @return [String] The normalized key input
      def Key(input) # rubocop:disable MethodName
        return input unless input.is_a?(::Enumerable)
        input.join(NAMESPACE_SEPARATOR).tap { |str| str.tr!('/', '.') }
      end
      module_function :Key # rubocop:disable AccessModifierDeclarations

      # Adds:
      #   * Key coercion capabilities to `Dry::Container::Mixin#register`
      #   * Reader for namespace_separator
      #
      # @example
      #   class Container
      #     include Dry::Container::Mixin
      #     include Piktur::Support::Container::Mixin
      #   end
      module Mixin

        # @!method Key(input)
        #   @param see (Container.Key)
        #   @return [String]
        define_method(:to_key, &Container.method(:Key).to_proc)

        # @see Dry::Container::Mixin#register
        def register(key, contents = nil, options = {}, &block)
          super(to_key(key), contents, options, &block)
        end

        # @!attribute [r] namespace_separator
        #   @return [String]
        def namespace_separator
          config.namespace_separator
        end

      end

      # :nodoc
      module Delegates

        # @!attribute [rw] container
        #   @return [Dry::Container] the {Container} instance
        attr_accessor :container

        # @!method register(key, contents = nil, options = {}, &block)
        #   @see https://github.com/dry-rb/dry-container/blob/master/lib/dry/container/mixin.rb
        #   @return [void]
        delegate :register, to: :container

        # @!method namespace(name, &block)
        #   @see Dry::Container::Mixin#namespace
        #   @return [void]
        delegate :namespace, to: :container

        # @!attribute [r] namespace_separator
        #   @return [String]
        delegate :namespace_separator, to: :container

        # @!method to_key(input)
        #   @param see (container#to_key)
        #   @return [String]
        delegate :to_key, to: :container

        # Returns the {.container} item registered under given `key`
        #
        # @param [String] key
        #
        # @raise [Dry::Container::Error] if nothing registered under `key`
        #
        # @return [Object]
        def [](key)
          container.resolve(key)
        rescue ::Dry::Container::Error => error
          ::Piktur.debug(binding, error: error)
        end
        alias resolve []

      end

    end

  end

end
