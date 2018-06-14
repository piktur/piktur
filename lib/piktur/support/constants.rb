# frozen_string_literal: true

require 'dry/core/constants'

module Piktur

  include ::Dry::Core::Constants

  # @return [String]
  Support::CLONE_WARNING = <<~MSG
    Use %{method} to make a copy of this class.
  MSG

  # @return [StandardError]
  MethodDefinedError = ::Class.new(::StandardError)

end
