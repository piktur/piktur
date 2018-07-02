# frozen_string_literal: true

module Piktur

  module Loader

    # Filter an autoloadable directory by component type
    class ByType < Filter

      # Returns a list of files within {Filters#target} matching `type`.
      #
      # @param [Symbol] type The component type
      #
      # @return [Proc]
      def call(type)
        # We should be flexible. Allow the match to proceed, fail, maybe,
        # and if so, return an empty array.
        # return unless types.include?(type)

        lambda do |type, pattern| # rubocop:disable ShadowingOuterLocalVariable
          root_directories.flat_map do |root|
            loader.fn[:get][root, type, pattern]
          end
        end.curry(2)[type]
      end

    end

  end

end
