# frozen_string_literal: true

module Piktur

  module Loader

    # Exposes the public loader interface.
    module Ext

      # @return [Piktur::Loader] the loader instance
      def loader
        ::Piktur::Config.loader[:instance]
      end

      # @example
      #   components_dir(root: ::Rails.root)
      #
      # @param [Pathname] root
      #
      # @return [Pathname] the relative path
      def components_dir(root: nil)
        return ::Piktur::Config.components_dir.expand_path(root) if root
        ::Piktur::Config.components_dir
      end

      # @param see (Loader::Filter#by_type)
      #
      # @return [Array<String>] A list of autoloadable file paths
      def files(type, pattern = nil)
        loader.send(:by_type, type, *pattern)
      end

      # @return [Array<String>] A list of locale files
      def locales
        ::Rails.configuration.i18n.load_path
      end

      # @!method models
      # @!method policies
      # @!method repositories
      # @!method schemas
      # @!method transactions
      # @return [Array<Pathname>]
      # %i(models policies repositories schemas transactions)
      #   .each { |aliaz| alias_method aliaz, :files }

      # Load namespaces and/or type defintions and dependencies on demand.
      #
      # @param [String] namespaces A list of namespaces - the relative path from
      #   {Piktur::Config.components_dir}
      # @param [Symbol] types A list of {Concepts::COMPONENTS}
      #
      # @option see (Loader::ActiveSupport#call)
      #
      # @return [void]
      def load(namespaces: nil, types: nil, **options)
        if namespaces.present?
          namespaces.each { |e| loader[namespace: e, **options] }
        elsif types.present?
          types.each { |e| loader[type: e, **options] }
        else # Load all {Piktur.namespaces}
          loader.call(options)
        end
      end

      # A reload will be trigged if called after application boot in non-production environments.
      #
      # @param [Array<String>] args
      # @param see (#load)
      #
      # @return [void]
      def load!(*args)
        load(*args, force: ::Piktur.loader.booted?)
      end

    end

  end

end
