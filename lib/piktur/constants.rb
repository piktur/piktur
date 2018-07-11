# frozen_string_literal: true

require 'dry/core/constants'

module Piktur # rubocop:disable Documentation

  # Constants you may use to avoid memory allocations or identity checks.
  module Constants

    def self.included(base)
      base.include ::Dry::Core::Constants
    end

    # @return [Pathname]
    ROOT_PATH = Pathname('/').freeze

    # @return [Pathname]
    EMPTY_PATH = Pathname('').freeze

    # @return [BasicObject]
    EMPTY_OBJECT = BasicObject.allocate

  end

  include Constants

  # @return [String]
  Support::CLONE_WARNING = <<~MSG
    Use %{method} to make a copy of this class.
  MSG

  # @return [StandardError]
  MethodDefinedError = ::Class.new(::StandardError)

end
