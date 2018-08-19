# frozen_string_literal: true

module Piktur

  module Loader

    # @see https://bitbucket.org/piktur/piktur_core/issues/39/
    module Index

      private

        # @todo
        #   Fetch what's needed when it's needed! DO NOT preload; unless in production --
        #   to be determined.
        #
        # @note {#index!} cannot be called until Piktur::Config is {Piktur::Config.finalize!}d.
        #
        # @see Filter#root_directories
        # @see #_flatten
        #
        # @return [String]
        def index!
          ::Piktur.debug(binding, warn: "[PERFORMANCE] #{__FILE__}:#{__LINE__}")

          _flatten(&fn[:set])
        end

        # Aggregates and indexes the contents of the {Filters#target} directory if it exists under
        # any of the {Filters#root_directories}
        #
        # @see #index!
        #
        # @return [void]
        def _flatten(&block)
          root_directories.flat_map do |root|
            _scan(root, &block)
          end
        end

        # Scans **all** files and sub-directories (recursive)
        #
        # @param [Pathname] root The directory to scan
        #
        # @yieldparam [Pathname] entry The nested path
        # @yieldparam [Pathname] parent The parent directory
        # @yieldparam [Pathname] root The root directory
        #
        # @return [void]
        def _scan(root)
          ::Piktur.debug(binding, warn: "[PERFORMANCE] #{__FILE__}:#{__LINE__}")

          return if root.nil?

          # Consider using {#_scan_directories} instead
          root.find do |path|
            # Only necessary when {#index!}ing the tree and {#index!} should not be necessary!
            ::Find.prune if type_directory?(path)

            yield(root, path) if block_given?
          end
        end

        # Returns all sub directories of root (recursive)
        #
        # @param [Pathname] root
        #
        # @return [void]
        def _scan_directories(root)
          return if root.nil?

          root.each_child do |path|
            next if path.file?
            yield(root, path) if block_given?
            _scan_directories(path)
          end
        end

    end

  end

end
