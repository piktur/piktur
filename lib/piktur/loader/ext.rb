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
      #   @return [Piktur::Loader::Base] The specified or default ({Piktur::Config.loader.instance})
      #     instance
      attr_writer :loader

      # @see (#loader=)
      def loader
        @loader ||= ::Piktur::Config.loader[:instance]
      end

      # @param see (Filters#files)
      #
      # @return [Array<String>] A list of autoloadable file paths
      def files(options = EMPTY_OPTS)
        Loader.files(loader, options)
      end

      # Load namespaces and/or type defintions and dependencies on demand.
      #
      # @param [String] namespaces A list of namespaces - the relative path from
      #   {Piktur::Config.components_dir}
      # @param [Symbol] types A list of {Piktur.component_types}
      #
      # @option see (Loader::ActiveSupport#call)
      # @option options [Boolean] :components (false) Index only
      #
      # @return [void]
      def load(options = EMPTY_OPTS)
        Loader.call(loader, options)
      end

      # If the reloader is enabled, forces a reload.
      #
      # @see file:lib/piktur/setup/boot.rb
      #
      # @param [Array<String>] args
      # @param see (#load)
      #
      # @return [void]
      def load!(options = EMPTY_OPTS)
        load(**options, force: ::Piktur.loader.booted?)
      end

    end

  end

end
