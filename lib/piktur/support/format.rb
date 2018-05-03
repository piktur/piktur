# frozen_string_literal: true

module Piktur

  module Support

    # Simple coercion functions
    module Format

      # @return [String]
      TIME_PATTERN = '%H:%M%p'

      # @param [String]
      Title = proc { |str| str.is_a?(String) ? str.squish.titleize : '' }

      # @param [String]
      # @param [String] pattern
      Time = proc { |str, pattern = TIME_PATTERN| str.to_time.strftime(pattern) }

    end

  end

end
