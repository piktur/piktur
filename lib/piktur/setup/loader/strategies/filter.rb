# frozen_string_literal: true

# rubocop:disable AccessModifierIndentation, AccessModifierDeclarations

module Piktur

  # :nodoc
  module Loader

    class << self

      # @!group Pattern Matching

      # @see Matcher::Glob
      #
      # @return [String]
      def pattern_template
        Matcher::Glob.safe_const_get(__callee__.upcase)
      end
      alias scoped_type_pattern pattern_template
      alias unscoped_type_pattern pattern_template
      alias namespace_pattern pattern_template

      # @!endgroup

      # @param [Pathname, String] root The base path
      # @param [Pathname, String] variant The variable element of the match `pattern`
      # @param [String] pattern The match pattern
      #
      # @return [Array<String>] A list of relative paths from root matching `pattern`
      def scoped_glob(root, variant, pattern)
        ::Dir[format(pattern, variant), base: root]
      end

      # @param see (#scoped_glob)
      #
      # @return [Array<String>] A list of absolute paths matching `pattern`
      def unscoped_glob(*args)
        ::Dir[args.join(::File::SEPARATOR)]
      end

    end

    # :nodoc
    module Filters

      # @group Scope

      # @!attribute [rw] target
      #   @return [Pathname] The managed directory name
      attr_writer :target

      # @example
      #   target(::Rails.root)
      #
      # @param [Pathname] root
      #
      # @return [Pathname] the relative path of the managed directory
      # @return [Pathname] if `root` the absolute path of the managed directory from root
      def target(root = nil)
        root ? @target.expand_path(root) : @target
      end

      # @!attribute [rw] types
      #   A list of component types (in {Piktur::Config.nouns}) form found in {#target}
      #   sub directories.
      #
      #   @return [Array<Symbol>]
      attr_reader :types

      # @see Piktur::Config.nouns
      #
      # @param [Array<String, Symbol>] arr A list of component types
      #
      # @return [void]
      def types=(arr)
        @types = arr.map { |type| ::Inflector.send(::Piktur.config[:nouns], type).to_sym }
      end

      # Returns a list of existent directories matching {#target}
      #
      # @return [Array<Pathname>]
      def root_directories
        @root_directories ||= ::Piktur.services
          .railties
          .map { |railtie| railtie.root / target }
          .select(&:exist?)
          .uniq # @see file:lib/piktur/engine/paths.rb {Piktur::Engine.itself?}
      end

      # @!endgroup

      # @param see (#by_path)
      # @param see (#by_type)
      #
      # @return [Array<String>]
      def files(path: nil, type: nil, **options)
        return by_type(type, options) if type
        return by_path(path, options) if path
        EMPTY_ARRAY
      end

      # @!group Sort

      # Returns the sorted path list
      #
      # @see Sorter
      #
      # @param [Symbol] namespace One of {Piktur::Config.namespaces}
      # @param [Symbol] index The name of the namespace index file
      # @param [Symbol] pattern The match pattern
      #
      # @return [Array<String>]
      def sort_by_path(namespace, index, pattern = nil)
        Sorter.call(by_path(namespace, *pattern), index)
      end

      # Returns the sorted path list
      #
      # @see Sorter
      #
      # @param [String] type One of {#types}
      # @param [Symbol] pattern The match pattern
      #
      # @return [Array<String>]
      def sort_by_type(type, pattern = nil)
        Sorter.call(by_type(type, *pattern), type)
      end

      # @!endgroup

      protected

        # @!group Filter

        # Returns a list of files within {#target} `path` matching the given `pattern`
        #
        # @param [Pathname, String] path An **autoloadable** path
        # @param [String] pattern The match pattern
        #
        # @see https://ruby-doc.org/core-2.2.0/File.html#method-c-fnmatch-3F
        #
        # @return [Array<Pathname>]
        def by_path(path, pattern: Loader.namespace_pattern)
          binding.pry
          fetch_or_store(path) { fn[:ByPath].call(path) }
            &.call(pattern) || EMPTY_ARRAY
        end

        # Returns a list of files within {#target} `namespace` matching the given `pattern`
        #
        # @param see (#by_path)
        #
        # @return [Array<Pathname>]
        alias by_namespace by_path

        # Returns a list of files within {#target} matching `type`
        #
        # @see https://bitbucket.org/piktur/piktur_core/src/master/spec/benchmark/pattern_matching.rb
        #   .dir_vs_pathname_glob
        #
        # @param [Symbol] type The component type
        # @param [String] pattern The match pattern
        # @param [String] scope Apply match pattern to sub directory scope
        #
        # @return [Array<String>] A list of autoloadable file paths
        def by_type(type, pattern: nil, scope: '**')
          fetch_or_store(type) { fn[:ByType].call(type) }
            .call(interpolate(type, pattern, *scope))
        end

        # @!endgroup

        # @!group Pattern Matching

        # @!attribute [r] matchers
        #   Returns a Hash mapping component type to a Regexp matching singular and plural
        #   forms of the type.
        #   @return [Hash{Symbol=>Regexp}]
        def matchers
          @matchers ||= ::Hash[types.map { |t| [t, Matcher.call(t)] }].freeze
        end

        # @!attribute [r] patterns
        #   Returns a Hash mapping component type to a pattern matching singular and plural
        #   forms of the type.
        #   @return [Hash{Symbol=>String}]
        def patterns
          @patterns ||= ::Hash[types.map { |t| [t, Matcher.call(t, glob: true)] }].freeze
        end

        # @see https://bitbucket.org/piktur/piktur/src/master/lib/piktur/support/pathname/matcher.rb
        #   Combine.regex
        #
        # @return [Regexp] {#matchers} union
        def matcher_combination
          @matcher_combination ||= Matcher.combine(types)
        end

        # @example
        #   ::Dir[*pattern_combination(:models, :schemas)] # => ['a/model.rb', 'a/schema.rb']
        #
        # @return [Array<String>] {#patterns}
        def pattern_combination(*types)
          patterns.values_at(*types)
        end

        # Apply substitutions to the given or default glob `pattern` according to `type`.
        #
        # @param [String] pattern An alternate glob template
        # @param [Symbol] type One of {#types}
        # @param [String] scope Restrict the scope of the glob to a directory namespace
        #
        # @return [String]
        private def interpolate(type, pattern = nil, scope = '**')
          format(pattern || patterns.fetch(type) { Loader.scoped_type_pattern }, scope, type)
        end

        # @!endgroup

    end

    # @see https://bitbucket.org/piktur/piktur_core/src/master/spec/benchmark/pattern_matching.rb
    #   .dir_vs_pathname_glob
    class Filter

      # @!attribute [r] loader
      #   @return [Object] The loader instance
      attr_reader :loader

      # @param [Pathname] target The managed directory
      # @param [Array<Pathname>] root_directories A list of existent directories matching {#target}
      def initialize(loader)
        @loader = loader
      end

      # @param [Pathname] path
      #
      # @return [Array<(Pathname, Pathname)>] The root and path if `path` exists
      # @return [nil] if `path` not found
      def find(path)
        root_directories.find do |root| # Only one should exist
          path = root.join(path)
          break([root, path]) if path.exist?
        end
      end

      protected

        # @see Filters#target
        def target; loader.target; end

        # @see Filters#root_directories
        def root_directories; loader.root_directories; end

        # @see Filters#types
        def types; loader.types; end

    end

  end

end
