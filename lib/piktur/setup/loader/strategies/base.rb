# frozen_string_literal: true

module Piktur

  module Loader

    module Base

      # @param [Module] base
      # @return [void]
      def self.included(base)
        base.extend ClassInterface
      end

      attr_reader :booted
      alias booted? booted

      def initialize
        @concepts = {}
        @loaded   = Set.new
        @booted   = false
      end

      # @return [Hash]
      def config; ::Piktur.config.loader; end
      def call(**options, &block); end
      def booted!; @booted = true; end
      def load!(name, groups: nil, force: false, **); end
      def load_all!(**options); end
      def reload!(files); end

      private

        def debug(concept, files: []); end
        def load_files(files, type = nil); end
        def unloadable(file, type = nil); end
        def relative_path(f); end
        def prepare_options!(options); end
        def merge!(concepts); end
        def insert!(pipeline, args); end
        def prepend!(pipeline, args); end
        def match(f); end
        def self.find_by_constant(); end
        def self.find_by_path(); end

    end

    # @todo HASHING OUT PREFERRED IMPLEMENTATION STILL A WAY TO GO YET
    module Pending

      # Again if you're going to use components dir you need to getting the absolute path for each
      # railtie.
      #
      # !! USE Piktur.services.files.type_matchers
      #
      # absolute = ::Piktur.components_dir(root: )
      # relative = absolute.relative_path_from(::Pathname.pwd)
      # AUTOLOAD_MATCHERS = COMPONENTS.each_with_object({}) do |type, h|
      #   glob = "**/#{::Inflector.singularize(type)}{*,**/*}.rb"
      #   # const_set("#{type.upcase}_MATCHER", glob)
      #   h[type] = relative.join(glob)
      # end.freeze


      # @example
      #   Users.path(:model)          # => 'users/model'
      #   Users.path(:schema)         # => 'users/schema'
      #   Users.path(:model, 'admin') # => 'admins/model'
      #
      # @param [String, Symbol] component_type
      # @param [String] variant
      #
      # @return [String] the relative path to the component definition
      def path(component_type, variant = DEFAULT_VARIANT)
        variant(component_type, variant, ::File::SEPARATOR)
      end

      # @raise [KeyError]
      # @return [String] if
      def find(component_type, variant = nil)
        # components_dir = Config.components_dir.relative_path_from(root)
        lookup_paths.fetch(component_type).each do |path|
          # components_dir.join(path.call[variant]).exist?
          result = path.call[variant]
          break(result) if ::File.exist?(result)
        end
      end

      # Returns the default lookup paths for
      #
      # @return [Array<Proc>]
      def lookup_paths
        return @_lookup_paths if defined?(@_lookup_path)
        dir = concept_name.plural
        @_lookup_paths = COMPONENTS.each_with_object({}) do |type, h|
          type_dir = ::Inflector.pluralize(type)
          h[type] = [
            ->(*)       { "#{dir}/#{type}" },
            ->(*)       { "#{dir}/#{type_dir}/#{Naming::DEFAULT_VARIANT}" },
            ->(variant) { "#{dir}/#{type_dir}/#{variant}" }
          ]
        end
      end

      # Tracks the constants dependencies and enables code reloading.
      #
      # @return [void]
      def load
        require_dependency find(component_type)
      end

    end

  end

end
