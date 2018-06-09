# frozen_string_literal: true

module Piktur

  module Loader

    module Ext

      # @return [Piktur::Loader] the loader instance
      def loader; ::Piktur['loader']; end

      # @example
      #   components_dir(root: ::Rails.root)
      #
      # @param [Pathname] root
      #
      # @return [Pathname] the relative path
      def components_dir(root: nil)
        return ::Piktur.config.components_dir.expand_path(root) if root
        ::Piktur.config.components_dir
      end

      # Load a concept and all dependencies on demand
      #
      # @param [String] name
      # @param [Hash] options
      #
      # @return [void]
      def load_concept!(name, **options)
        loader.load!(name, options)
      end

      # @param [Array<String>] args
      # @param [Hash] options
      #
      # @return [void]
      def load_concepts!(*args, **options)
        if args.present?
          args.all? { |name| loader.load!(name, options) }
        else
          loader.load_all!(options)
        end
      end

    end

  end

end
