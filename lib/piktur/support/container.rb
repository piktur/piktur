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
      autoload :Key, 'piktur/support/container'

      # Adds:
      #   * Key coercion capabilities to `Dry::Container::Mixin#register`
      #   * Reader for namespace_separator
      #
      module Key

        # @return [String]
        def namespace_separator; config.namespace_separator; end

        # @return [String] The normalized key input
        def to_key(input)
          case input
          when ::Enumerable
            input.join(namespace_separator).tap { |str| str.tr!('/', namespace_separator) }
          when ::String
            input.tr('/', namespace_separator)
          else
            input
          end
        end

      end

      # @example
      #   class Container
      #     include Dry::Container::Mixin
      #     include Piktur::Support::Container::Mixin
      #   end
      module Mixin

        include Key

        # @see Dry::Container::Mixin#register
        def register(key, contents = nil, options = {}, &block)
          super(to_key(key), contents, options, &block)
        end

        # @note memoized container items use the same mutex instance!
        #
        # @return [Dry::Container{String => Object}] a mutable copy of the container
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
