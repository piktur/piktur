# frozen_string_literal: true

module Piktur

  module Loader

    # @todo
    class Dry

      include Base

      # Configure Auto-Registration for ROM components
      component_dirs = Piktur::DB::COMPONENT_DIRS
      matcher = Piktur::Loader::Matcher
      globs = component_dirs.map do |type|
        matcher.call(type, glob: true, path: Piktur.components_dir)
      end

      ROM::AutoRegistration.class_eval do
        def require(file)
          require_dependency(file)
        end
      end

      # Piktur::DB.configuration.auto_registration(
      #   Piktur.components_dir,
      #   namespace: 'Object',
      #   globs:     Hash[component_dirs.zip(globs)]
      # )

      # @param [Hash] options
      #
      # @option options [String] :namespace (nil)
      # @option options [Symbol] :type (nil)
      #
      # @raise [LoadError]
      #
      # @return [void]
      def call(namespace: nil, type: nil, **options)
        # @example Prefetch (disabled -- likely unnecessary)
        #
        #   index! unless booted?

        if namespace
          load_namespace!(namespace, options)
        elsif type
          load_type!(type, options)
        else
          load_all!(options)
        end

        booted! unless booted
      rescue ::LoadError => error
        ::Piktur.debug(binding, error: error)
      end
      alias [] call

    end

  end

end
