# frozen_string_literal: true

module Piktur

  # :nodoc
  module Loader

    # Provides an interface to the loader instance.
    #
    # @see Filters#files
    # @see Load#load_path!
    # @see Load#load_type!
    module Ext

      # @!attribute [rw] loader
      #   @return [Loader::Base] The specified or default ({Interface.loader})
      #     instance
      attr_writer :loader

      # @see (#loader=)
      def loader
        @loader || ::NAMESPACE.config.loader.instance
      end

      # @param see (Filters#files)
      #
      # @return [Array<String>] A list of autoloadable file paths
      def files(options = EMPTY_OPTS)
        Loader.files(loader, options)
      end

      # @option see (Loader::ActiveSupport#call)
      # @option options [Boolean] :components (false) Index only
      #
      # @return [void]
      def load(options = EMPTY_OPTS)
        Loader.call(loader, options)
      end

      # If the reloader is enabled, forces a reload.
      #
      # @see https://bitbucket.org/piktur/piktur_core/src/master/lib/piktur/setup/boot.rb
      #
      # @param [Array<String>] args
      # @param see (#load)
      #
      # @return [void]
      def load!(options = EMPTY_OPTS)
        load(**options, force: ::NAMESPACE.loader.booted?)
      end

    end

  end

end
