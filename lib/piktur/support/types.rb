# frozen_string_literal: true

require 'dry/types'

Dry::Types.load_extensions(:maybe)

module Piktur

  module Support

    # Namespace including `Dry::Types` and a {.container} to register application specific types.
    #
    # @note For compatibility with Dry::Struct, custom types SHOULD implemenent the
    #   Dry::Types interface
    #
    # @note Custom types defined within`lib/<namespace>/types.rb` will be loaded and if listed
    #   within {.to_register} block, registered with the {Container} when it is initialized.
    #
    # @example Usage
    #   Support.install(:types)
    #
    # @example Value objects
    #   NAMESPACE::Types['address']                         # => Address
    #   NAMESPACE::Types['address'].(city: '', country: '') # => <Address city='' country=''>
    #   NAMESPACE::Types['undefined']                       # raise Dry::Container::Error
    #
    # @example Enums
    #   NAMESPACE::Types['enum.users.types'][:admin] # => <Enum::Value admin=1>
    module Types

      # @return [String]
      CUSTOM_TYPES_PATH = ::File.expand_path(
        "./lib/#{Support::Inflector.underscore(::NAMESPACE.to_s)}/types.rb",
        ::Dir.pwd
      )

      # :nodoc
      class Container

        include ::Dry::Container::Mixin
        include Support::Container::Mixin

        def self.new(*)
          super.tap do |container|
            container.merge(::Dry::Types.container)

            if ::File.exist?(CUSTOM_TYPES_PATH)
              ::Kernel.load(CUSTOM_TYPES_PATH)

              block = Types.instance_variable_get(:@registrar)
              container.instance_eval(&block) if block
            end
          end
        end

        # @return [void]
        def finalize!
          freeze if ::NAMESPACE.env.production?
        end

      end

      include ::Dry::Types.module
      extend  Support::Container::Delegates

      # Alias `Int` to resolve breaking name change in 0.13
      # @see https://github.com/rom-rb/rom-sql/blob/master/lib/rom/sql/extensions/postgres/types.rb
      Int = Integer unless const_defined?(:Int)
      Strict::Int = Strict::Integer unless Strict.const_defined?(:Int)
      Coercible::Int = Coercible::Integer unless Coercible.const_defined?(:Int)
      Coercible::Symbol = Dry::Types['symbol']

      Dry::Types.register('coercible.symbol', Coercible::Symbol)

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

        # @!attribute [rw] container
        #   @return [Dry::Container{String => Object}]
        def container; @container ||= Container.new; end

        # Builds a {Piktur::Support::Enum} and registers the type caster with the {.container}
        #
        # @param see (Piktur::Support::Enum.new)
        #
        # @example
        #   Types['enum.users.types'][:admin] # => <Enum::Value admin=3>
        #
        # @raise [Dry::Container::Error] if existing key
        #
        # @return [Dry::Types::Constructor]
        def Enum(*args, &block) # rubocop:disable MethodName
          enum = Support::Enum.new(*args, &block)

          constructor = ::Dry::Types['integer'].constructor(&enum.method(:[]))
          container.register(enum.key, constructor, call: false)
          enum
        rescue ::Dry::Container::Error => err
          ::NAMESPACE.debug(binding, error: err)
        end

        # Register a model constructor with {.container}
        #
        # @param [String, Symbol] key The key to register
        # @param [Object] constructor Any object implementing `#call(params)`
        #
        # @raise [Dry::Container::Error] if existing key
        #
        # @return [Dry::Types::Constructor] The given constructor
        # @return [nil] if The constructor does not respond to `#call(params)`
        def Model(key, klass) # rubocop:disable MethodName
          return unless klass.respond_to?(:call) && !(fn = klass.method(:call)).arity.zero?

          constructor = Constructor(klass, &fn)
          container.register(key, constructor, call: false)
          constructor
        rescue ::Dry::Container::Error => err
          ::NAMESPACE.debug(binding, error: err)
        end

        # @see https://github.com/rom-rb/rom-rails/blob/master/lib/generators/rom/install/templates/types.rb
        # @return [Dry::Types::Sum]
        def ID(*) # rubocop:disable MethodName
          Coercible::Integer.optional.meta(primary_key: true)
        end

        # List types to register after container initialization.
        #
        # @return [void]
        def to_register(&block)
          @registrar = block
        end

        private

          # @return [void]
          def install(*)
            ::NAMESPACE.const_set(:Types, self)
            true
          end

      end

    end

  end

end
