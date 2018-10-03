# frozen_string_literal: true

module Piktur

  module Loader

    # :nodoc
    module Predicates

      # @!group Predicates

      # @param [Pathname] path
      # @param [Pathname] target
      #
      # @return [true] if path name eq {Filters#target} name
      def target?(path, target = self.target)
        return false if path.nil?

        Path.basename_match?(target, path) # target.basename == path.basename
      end

      # @param [Pathname] path
      #
      # @return [true] if `path` is a child of {Filters#target}
      def child?(path)
        target?(path.parent)
      end

      # @param [Pathname] path
      #
      # @return [true] if `path` is a file and a child of {Filters#target}
      def leaf?(path)
        path.file? && child?(path)
      end

      # @param [Pathname] path
      #
      # @return [true] if `path` is a directory and a child of {Filters#target}
      def branch?(path)
        path.directory? && child?(path)
      end

      # Filter type directories from "concept" directories
      #
      # @param [Pathname] path
      #
      # @return [true] if path is a directory and matches {Filters#matcher_combination}
      def type_directory?(path)
        return false if path.nil?

        path.directory? && Path.match?(path, matcher_combination)
      end

      # @!endgroup

    end

  end

end
