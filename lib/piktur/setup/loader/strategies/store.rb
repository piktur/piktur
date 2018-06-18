# frozen_string_literal: true

require 'dry/core/cache'

module Piktur

  module Loader

    # Implements caching for a Loader instance.
    module Store

      # @param [Module] base
      #
      # @return [void]
      #
      # @api private
      def self.included(base)
        base.extend ::Dry::Core::Cache
      end

      private

        # @return [Concurrent::Map]
        def cache; self.class.cache; end

        # Assigns `value` as both `path` and {Path.relative_path_from_target} allowing retrieval on:
        #   * load   -- where the provided key is likely to be a relative path
        #   * reload -- where the provided key will be an absolute path
        #
        # @param [Pathname] root The root path of the service owning the path
        # @param [Pathname] path The absolute path to the directory
        # @param [Pathname] value The value to cache
        #
        # @return [void]
        def _store_path(root, path, value = nil)
          return if path.nil? || target?(path, root)

          value ||= prepare(root, path)

          if path.directory?
            _store(Path.relative_path_from_target(path, target), value)
          else
            _store(path, value)
          end
        end

        # Assigns the given `value` to the hash value of `key_elements`.
        #
        # @param [Pathname] key_elements
        # @param [Pathname] value
        #
        # @return [void]
        def _store(*key_elements, value)
          cache.put(_key(*key_elements), value)
        end

        # Generates a Fixnum hash value from the given `args`
        #
        # @see https://ruby-doc.org/core-2.2.0/Object.html#method-i-hash
        #
        # @param [String] args
        #
        # @return [Fixnum]
        def _key(*args); args.hash; end

    end

  end

end
