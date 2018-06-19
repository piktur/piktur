# frozen_string_literal: true

module Piktur

  module Loader

    # Filter an autoloadable directory by path (namespace).
    class ByPath < Filter

      # Returns a function which, when called with a `pattern`,
      # will return the **current** contents of the `path` where
      # given `pattern` matches.
      #
      # @param [Pathname] path The path to scan
      #
      # @return [Proc]
      def call(path)
        # Disregard if `path` is a {Predicates#leaf?}
        return if (root, path = find(path)).nil? || loader.leaf?(path)

        # The glob is scoped to the parent directory so that,
        # when reloading, any **modified** file present in the changes payload
        # could be used to retrieve the contents of the parent directory.
        path = path.parent if path.file?

        loader.fn[:get].curry(3)[root, Path.right_of(path, root)]
      end

      # Returns a list of {Filters#target} level **index** files
      #
      # @return [Array<String>]
      def indices
        loader.root_directories.flat_map { |root| ::Dir['*.rb', base: root] }
      end

    end

  end

end
