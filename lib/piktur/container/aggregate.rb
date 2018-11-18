# frozen_string_literal: true

module Piktur

  # Centralized container access.
  class Container::Aggregate < ::BasicObject # rubocop:disable ClassAndModuleChildren

    # @!attribute [rw] main
    #   @return [Dry::Container{String => Object}]
    attr_writer :main
    def main; @main ||= ::Piktur::Container::Main.new; end
    alias container main
    alias container= main=

    # @!attribute [rw] operations
    #   @return [Dry::Container{String => Object}]
    attr_writer :operations
    def operations; @operations ||= ::Piktur::Operations::Container.new; end

    # @!attribute [rw] types
    #   @return [Dry::Container{String => Object}]
    attr_writer :types
    def types; @types ||= ::Piktur::Types::Container.new; end

    # @return [Array<Dry::Container{String => Object}>]
    def to_a; [main, operations, types]; end

    # @yieldparam [Dry::Container{String => Object}] container
    #
    # @return [Enumerator]
    def each(&block); to_a.each(&block); end

  end

end
