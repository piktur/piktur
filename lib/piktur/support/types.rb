# frozen_string_literal: true

require 'dry/types'

Dry::Types.load_extensions(:maybe)

module Piktur

  module Support

    # Namespace including `Dry::Types` and a {.container} to register application specific types.
    #
    # @example Usage
    #   Support.install(:types)
    #
    # @example Value objects
    #   Piktur::Types['address']                         # => Address
    #   Piktur::Types['address'].(city: '', country: '') # => <Address city='' country=''>
    #   Piktur::Types['undefined']                       # raise Dry::Container::Error
    #
    # @example Enums
    #   Piktur::Types['enum.address.types][:billing]     # => <Enum::Value billing=1>
    module Types

      # :nodoc
      class Container

        include ::Dry::Container::Mixin
        include Support::Container::Mixin

        # @return [void]
        def finalize!
          freeze if ::Piktur.env.production?
        end

      end

      include ::Dry::Types.module
      extend  Support::Container::Delegates

      # Alias `Int` to resolve breaking name change in 0.13
      # @see https://github.com/rom-rb/rom-sql/blob/master/lib/rom/sql/extensions/postgres/types.rb
      Int = Integer unless const_defined?(:Int)
      Strict::Int = Strict::Integer unless Strict.const_defined?(:Int)
      Coercible::Int = Coercible::Integer unless Coercible.const_defined?(:Int)

      class << self

        # @param [Module] base
        #
        # @raise [Piktur::MethodDefinedError] if `:[]` already defined on `base`.
        # @return [void]
        def included(base)
          raise(MethodDefinedError, "#{base}.[] already defined") if
            base.method_defined?(:[])

          def base.[](key); ::Piktur::Types[key]; end
        end

        # @!attribute [r] container
        #   @return [Dry::Container{String => Object}]
        def container
          @container ||= Container.new
        end

        # Builds a {Piktur::Support::Enum} and registers the type caster with the {.container}
        #
        # @param see (Enum::Constructor)
        #
        # @example
        #   Types['enum.users.types'][:admin] # => <Enum::Value admin=3>
        #
        # @raise [Dry::Container::Error] if existing key
        #
        # @return [Enum]
        def Enum(*args, &block) # rubocop:disable MethodName
          enum = Support::Enum.new(*args, &block)

          # Register the type caster
          container.register(enum.key, enum.method(:[]).to_proc, call: false, memoize: false)
          enum
        end

        # Register a model constructor with {.container}
        #
        # @param [String, Symbol] key The key to register
        # @param [Object] constructor Any object implementing `#call(params)`
        #
        # @raise [Dry::Container::Error] if existing key
        #
        # @return [Object] The given constructor
        # @return [nil] if The constructor does not respond to `#call(params)`
        def Model(key, constructor) # rubocop:disable MethodName
          return unless constructor.respond_to?(:call) && constructor.arity == 1

          container.register(key, constructor, call: false, memoize: false)
          constructor
        rescue ::Dry::Container::Error => error
          ::Piktur.debug(binding, error: error)
        end

        # @see https://github.com/rom-rb/rom-rails/blob/master/lib/generators/rom/install/templates/types.rb
        # @return [Dry::Types::Sum]
        def ID(*) # rubocop:disable MethodName
          Coercible::Integer.optional.meta(primary_key: true)
        end

        private

          # @return [void]
          def install(*)
            ::Piktur.const_set(:Types, self)
            true
          end

      end

    end

  end

end
