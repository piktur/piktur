# frozen_string_literal: true

require 'dry/configurable'

module Piktur

  # @todo await stable dry-configurable release, master introduces breaking changes and is
  #   incompatible with dry-validation.
  module Configurable

    def self.extended(base)
      base.extend ::Dry::Configurable
      base.safe_const_set(:Types, ::NAMESPACE::Types)
    end

    # @todo FIX conflict when class extended by Dry::Container::Mixin
    #
    # def [](name); config[name]; end

    # @see https://github.com/dry-rb/dry-configurable/commit/abefc03b945fb39349461b46b9b3a7aefc77a2ad
    #
    # Finalize and freeze configuration
    #
    # @return [Dry::Configurable::Config]
    #
    # @api public
    def finalize!
      return unless ::NAMESPACE.env.production?

      config.finalize!
      freeze
    end

  end

end

Dry::Configurable.prepend Piktur::Configurable
