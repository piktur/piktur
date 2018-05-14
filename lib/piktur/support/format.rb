# frozen_string_literal: true

module Piktur

  module Support

    # Simple coercion functions
    module Format

      # @return [String]
      TIME_PATTERN = '%H:%M%p'

      module_function

      # @param [String]
      def title(str); str.is_a?(String) ? str.squish.titleize : ''; end

      # @param [String]
      # @param [String] pattern
      def time(str, pattern = TIME_PATTERN); str.to_time.strftime(pattern); end

    end

  end

end
