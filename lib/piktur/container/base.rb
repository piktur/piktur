# frozen_string_literal: true

module Piktur::Container # rubocop:disable ClassAndModuleChildren

  class Base # rubocop:disable Documentation

    include ::Dry::Container::Mixin
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

    # @return [void]
    def finalize!; end

  end

end
