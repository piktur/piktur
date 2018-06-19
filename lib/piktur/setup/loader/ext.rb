# frozen_string_literal: true

module Piktur

  # :nodoc
  module Loader

    # Exposes the public loader interface.
    module Ext

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

      # @return [Array<Symbol>] A list of the component types implemented
      def component_types
        ::Piktur::Config.component_types
      end

      # @param see (Loader::Filter#by_type)
      #
      # @return [Array<String>] A list of autoloadable file paths
      def files(*args)
        loader.send(:by_type, *args)
      end

      # @return [Piktur::Loader] the loader instance
      def loader
        ::Piktur::Config.loader[:instance]
      end

      # Load namespaces and/or type defintions and dependencies on demand.
      #
      # @param [String] namespaces A list of namespaces - the relative path from
      #   {Piktur::Config.components_dir}
      # @param [Symbol] types A list of {Piktur.component_types}
      #
      # @option see (Loader::ActiveSupport#call)
      #
      # @return [void]
      def load(options = EMPTY_OPTS)
        options, filter, to_load = Loader.prepare_options(options)

        if to_load
          if to_load.is_a?(Enumerable)
            to_load.each { |e| loader[options.update(filter => e)] }
          else
            loader[options.update(filter => to_load)]
          end
        else # Load all {Piktur.namespaces}
          loader.call(options)
        end
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

      # @!method models
      # @!method policies
      # @!method repositories
      # @!method schemas
      # @!method transactions
      #
      # @example
      #   model_paths = [Pathname('model_a.rb'), Pathname('model_b.rb')]
      #   models      = model_paths.map do
      #     root, target, path = rpartition(path, target)
      #     const = Inflector.classify(path)
      #     Inflector.constantize(const)
      #   end
      #
      #   # And with this list, build a JSON representation of the application schema
      #   Piktur::Schema.call(models).to_json
      #   # => {
      #   #   "user": {
      #   #     "attribute": {
      #   #       "type": "String",
      #   #       "required": true
      #   #     }
      #   #   },
      #   #   "catalogueItems": { ... }
      #   # }
      #
      # @return [Array<String>]
      # %i(models policies repositories schemas transactions)
      #   .each { |aliaz| alias_method aliaz, :files }

      # @return [Array<String>] A list of locale files
      def locales
        ::Rails.configuration.i18n.load_path
      end

    end

    # @param see (#load)
    #
    # @return [Array<(Hash, Symbol, Object)>]
    def self.prepare_options(namespaces: nil, type: nil, **options)
      # (to_load = options.delete(:namespaces)) && (filter = :namespace) ||
      #     (to_load = options.delete(:types)) && (filter = :type)

      if namespaces
        [options, :namespace, namespaces]
      elsif type
        # options[:pattern] = scoped_type_pattern if options[:scope]
        [options, :type, type]
      else
        options
      end
    end

  end

end
