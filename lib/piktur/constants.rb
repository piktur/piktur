# frozen_string_literal: true

require 'dry/core/constants'

module Piktur

  # Constants you may use to avoid memory allocations or identity checks.
  module Constants

    include ::Dry::Core::Constants

    # @return [Pathname]
    ROOT_PATH = Pathname('/').freeze

    # @return [Pathname]
    EMPTY_PATH = Pathname(EMPTY_STRING).freeze

    # @return [BasicObject]
    EMPTY_OBJECT = BasicObject.allocate

    def self.install(*)
      Support.install(:object, :module)
      constants.each { |const| ::Object.safe_const_set(const, const_get(const)) }
    end

  end

end
