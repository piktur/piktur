# frozen_string_literal: true

# rubocop:disable ClassAndModuleChildren, Documentation

module Piktur::Container::Delegates

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
  def namespace_separator; container&.namespace_separator; end

  # @!method to_key(input)
  #   @param see (container#to_key)
  #   @return [String]
  def to_key(input); container&.to_key(input); end

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
