# frozen_string_literal: true

module Piktur

  # :nodoc
  module Deprecation

    class << self

      # Log deprecation warning
      #
      # @example
      #   Deprecation[__method__, __FILE__, __LINE__]
      #
      # @param [Object] object The deprecated functionality
      # @param [String] path The file path
      # @param [String] line The line number
      #
      # @return [void]
      def call(object, *path)
        parent.logger.warn <<~MSG
          DEPRECATION WARNING: You are using deprecated behavior which will be removed
          from the next release. (#{object} at #{path.join(':')})
        MSG
      end
      alias [] call

    end

  end

end
