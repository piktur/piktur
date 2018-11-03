# frozen_string_literal: true

module Piktur::Support::Enum # rubocop:disable ClassAndModuleChildren

  # :nodoc
  class Config

    extend ::Dry::Configurable

    # @!attribute [rw] inflector
    #  @return [Object]
    setting :inflector, reader: true

    # @!attribute [rw] container
    #   @return [Object]
    setting :container, reader: true

    # @!attribute [rw] types
    #   @return [Object]
    setting :types, reader: true

    # @!attribute [rw] i18n_namespace
    #   @return [Symbol]
    setting :i18n_namespace, :enum, reader: true, &:to_sym

  end

end
