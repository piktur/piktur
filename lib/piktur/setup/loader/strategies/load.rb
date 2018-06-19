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
        # @param see (Loader::Load#load!)
        #
        # @return [void]
        def load_path!(namespace, force: false, **options)
          load(namespace, by_path(namespace, options), options)
        end
        alias load_namespace! load_path!

        # Load all paths matching `type`
        #
        # @see {Filter#types}
        #
        # @param see (Loader::Load#load!)
        #
        # @return [void]
        def load_type!(type, force: false, **options)
          load(type, by_type(type, options), options)
        end

        # Load all namespaces in {Piktur.config.namespaces}
        #
        # @param see (Loader::Load#load!)
        #
        # @return [void]
        def load_all!(options = EMPTY_OPTS)
          ::Piktur.namespaces.each { |namespace| load_path!(namespace, options) }
        end

        # @param [String, Symbol] id A type, namespace or path identifier
        # @param [Array<String>] paths
        # @param [Hash] options
        #
        # @option options [String] :pattern (String)
        # @option options [Boolean] :force (false)
        #
        # @return [void]
        def load(id, paths, force: false, **)
          return if !force && loaded?(id)

          catch(:abort) do
            super(paths, &self.class.default_proc)
            debug(paths)

            # Add the id to history
            loaded << id.to_s

            return true
          end

          ::Piktur.debug(binding, error: "Could not load #{id} #{__FILE__}:#{__LINE__}")
        end

    end

  end

end
