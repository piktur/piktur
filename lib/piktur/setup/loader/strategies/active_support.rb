# frozen_string_literal: true

module Piktur

  module Loader

    # Implements loading mechanism utilising `ActiveSupport::Dependencies.require_dependency`.
    #
    # @note It is expected that:
    #   * files located under `app/models` or files named `model.rb` define a "model" and the
    #     definition is assigned to a constant matching the file or directory name.
    #   * {#target} must also be added to `ActiveSupport::Dependencies.autoload_paths`.
    #   Model definitions must be added to the list of `explicitly_unloadable_constants` with
    #   `ActiveSupport::Dependencies.unloadable(const)`. Constants defined within these files
    #   will not be cleared otherwise.
    #
    # {include:Load}
    # {include:Filter}
    # {include:Store}
    class ActiveSupport

      include Loader::Base

      self.use_relative = true

      self.default_proc = lambda do |file|
        require_dependency(file)
      rescue NameError, LoadError => error
        ::Piktur.debug(binding, error: error)
      end

      # @param [Hash] options
      #
      # @option options [String] :namespace (nil)
      # @option options [Symbol] :type (nil)
      #
      # @raise [LoadError]
      #
      # @return [void]
      def call(namespace: nil, type: nil, **options)
        # Disable preloading for now
        # index! unless booted?

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

    end

  end

end
