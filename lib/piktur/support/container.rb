# frozen_string_literal: true

require 'dry/container'
require 'dry/monads'

module Piktur

  module Support

    # :nodoc
    module Container

      extend ::ActiveSupport::Autoload

      autoload :Delegates, 'piktur/support/container'
      autoload :Mixin, 'piktur/support/container'

      # @return [String]
      NAMESPACE_SEPARATOR = '.'

      # @return [String] The normalized key input
      def Key(input) # rubocop:disable MethodName
        return input unless input.is_a?(::Enumerable)
        input.join(NAMESPACE_SEPARATOR).tap { |str| str.tr!('/', '.') }
      end
      module_function :Key

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
        define_method(:to_key, &Container.method(:Key))

        # @see Dry::Container::Mixin#register
        def register(key, contents = nil, options = {}, &block)
          super(to_key(key), contents, options, &block)
        end

        # @!attribute [r] namespace_separator
        #   @return [String]
        def namespace_separator
          config.namespace_separator
        end

        # @note memoized container items use the same mutex instance!
        #
        # @return [Dry::Container] a mutable copy of the container
        def clone(freeze: false)
          super(freeze: freeze).tap do |obj|
            obj.instance_variables.each do |ivar|
              obj.instance_variable_set(
                ivar,
                obj.instance_variable_get(ivar).clone(freeze: freeze)
              )
            end
          end
        end

      end

      # :nodoc
      module Delegates

        # @!attribute [rw] container
        #   @return [Dry::Container{String => Object}] the {Container} instance
        attr_accessor :container

        # @!method register(key, contents = nil, options = {}, &block)
        #   @see https://github.com/dry-rb/dry-container/blob/master/lib/dry/container/mixin.rb
        #   @return [void]
        delegate :register, to: :container, allow_nil: true

        # @!method namespace(name, &block)
        #   @see Dry::Container::Mixin#namespace
        #   @return [void]
        delegate :namespace, to: :container, allow_nil: true

        # @!attribute [r] namespace_separator
        #   @return [String]
        delegate :namespace_separator, to: :container, allow_nil: true

        # @!method to_key(input)
        #   @param see (container#to_key)
        #   @return [String]
        delegate :to_key, to: :container, allow_nil: true

        # Returns the {.container} item registered under given `key`
        #
        # @param [String] key
        #
        # @raise [Dry::Container::Error] if nothing registered under `key`
        #
        # @return [Object]
        def [](key)
          container.resolve(key)
        rescue ::Dry::Container::Error => err
          ::NAMESPACE.debug(binding, raise: err)
        end
        alias resolve []

      end

    end

  end

end
