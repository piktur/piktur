# frozen_string_literal: true

module Piktur

  module Loader

    # Provides methods to query the file system and load the resulting files.
    module Load

      include Reload

      protected

        # Load path and dependencies matching `namespace` on demand.
        # The namespace may be a relative path from {Filters#target}
        #
        # @param see (#load)
        #
        # @return [Array<String>] The loaded paths
        # @return [nil] if {#loaded?} and force false
        def load_path!(namespace, force: false, **options)
          return if loaded?(namespace) && !force
          load(namespace, by_path(namespace, options), options)
        end
        alias load_namespace! load_path!

        # Load all paths matching `type`
        #
        # @see {Filter#types}
        #
        # @param see (#load)
        #
        # @return [Array<String>] The loaded paths
        # @return [nil] if {#loaded?} and force false
        def load_type!(type, force: false, **options)
          return if loaded?(type) && !force
          load(type, by_type(type, options), options)
        end

        # Load all namespaces in {Piktur.config.namespaces}
        #
        # @param see (#load)
        #
        # @return [Array<String>] The loaded paths
        def load_all!(options = EMPTY_OPTS)
          ::Piktur.namespaces.flat_map { |namespace| load_path!(namespace, options) }
        end

        # @param [String, Symbol] id A type, namespace or path identifier
        # @param [Array<String>] paths
        # @param [Hash] options
        #
        # @option options [String] :pattern (String)
        # @option options [Boolean] :force (false)
        #
        # @return [Array<String>] The loaded paths
        def load(id, paths, *)
          error = catch(:abort) do
            super(paths, &self.class.default_proc)
            debug(paths)

            # Add the id to history
            loaded << id.to_s

            booted! unless booted?

            return paths
          end

          ::Piktur.debug(binding, error: "[#{error}] Could not load #{id} #{__FILE__}:#{__LINE__}")
        end

    end

  end

end
