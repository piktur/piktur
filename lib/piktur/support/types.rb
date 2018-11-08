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

      extend ::ActiveSupport::Autoload

      autoload :Container

      include ::Dry::Types.module

      require_relative './types/container.rb'

      # Alias `Int` to resolve breaking name change in dry-types v0.13
      # @see https://github.com/rom-rb/rom-sql/blob/master/lib/rom/sql/extensions/postgres/types.rb
      Int = Integer unless const_defined?(:Int)
      Strict::Int = Strict::Integer unless Strict.const_defined?(:Int)
      Coercible::Int = Coercible::Integer unless Coercible.const_defined?(:Int)
      Coercible::Symbol = ::Dry::Types['symbol'].constructor(&:to_sym)

      ::Dry::Types.register('coercible.symbol', Coercible::Symbol)

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
