# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

module Piktur

  module Support

    # Namespace including Dry::Types and a container to register application specific types.
    #
    # @todo Items must be explictly registered or, if registered when on load, the definition
    #   must be loaded before key fetch.
    #
    # @example
    #   Piktur::Types['address']                         # => Address
    #   Piktur::Types['address'].(city: '', country: '') # <Address city='' country=''>
    #   Piktur::Types['entities.undefined']              # raise Dry::Container::Error
    module Types

      extend  ::Dry::Container::Mixin
      include ::Dry::Types.module

      Enum     = Module.new
      Entities = Module.new

      # @param [Module] base
      # @raise [Piktur::MethodDefinedError] if `:[]` already defined on `base`.
      # @return [void]
      def self.included(base)
        raise(MethodDefinedError, "#{base}.[] already defined") if
          base.method_defined?(:[])
        def base.[](key); ::Piktur::Types[key]; end
      end

      # @return [void]
      def self.install(*)
        ::Piktur.const_set(:Types, self)
        true
      end

      # def self.const_missing(const)
      #   ::Dry::Types.const_missing(const)
      # end

    end

  end

end
