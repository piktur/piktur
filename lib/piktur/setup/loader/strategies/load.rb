# frozen_string_literal: true

module Piktur

  module Loader

    # Implements the loading mechanism for a Loader instance.
    module Load

      include Reload

      protected

        # Load path and dependencies matching `namespace` on demand. The namespace may be a relative
        # path from {#target}
        #
        # @param see (Loader::Load#load!)
        #
        # @return [void]
        def load_path!(namespace, options = EMPTY_HASH)
          load!(namespace, by_path(namespace, *options[:pattern]), options)
        end
        alias load_namespace! load_path!

        # Load all paths matching `type`
        #
        # @see {Filter#types}
        #
        # @param see (Loader::Load#load!)
        #
        # @return [void]
        def load_type!(type, options = EMPTY_HASH)
          load!(type, by_type(type, *options[:pattern]), options)
        end

        # Load all namespaces in {Piktur.config.namespaces}
        #
        # @param see (Loader::Load#load!)
        #
        # @return [void]
        def load_all!(options = EMPTY_HASH)
          ::Piktur.config.namespaces.each { |namespace| load_path!(namespace, options) }
        end

        # @param [String, Symbol] id A type, namespace or path identifier
        # @param [Array<String>] paths
        # @param [Hash] options
        #
        # @option options [String] :pattern (String)
        # @option options [Boolean] :force (false)
        #
        # @return [void]
        def load!(id, paths, force: false, **)
          return if !force && loaded?(id)

          catch(:abort) do
            load(paths, &self.class.default_proc)
            debug(paths)
            loaded << id.to_s
            return
          end

          ::Piktur.debug(binding, error: "Could not load #{id} #{__FILE__}:#{__LINE__}")
        end

    end

  end

end
