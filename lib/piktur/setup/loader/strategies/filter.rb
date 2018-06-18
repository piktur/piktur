# frozen_string_literal: true

module Piktur

  module Loader

    # @note Ideally any directory **NOT** matching {#patterns} could be considered a component
    #   group -- {Piktur::Concepts}. But this is not ideal.
    module Filter

      # @see Matcher::Glob
      NAMESPACE_PATTERN = Matcher::Glob::NAMESPACE_PATTERN
      # @see Matcher::Glob
      TYPE_PATTERN = Matcher::Glob::TYPE_PATTERN

      # @!attribute [r] types
      #   A list of component types (plural) found in {#target} sub directories
      #   @return [Array<Symbol>]
      attr_reader :types

      # @group Scope

      # The managed directory name
      #
      # @return [Pathname]
      def target; ::Piktur.components_dir; end

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

      # Returns the sorted path list
      #
      # @see Support::Pathname::Sorter
      #
      # @param [Symbol] path One of {#types} or {Piktur::Config.namespaces}
      # @param [Symbol] variant The name of the primary component variant
      # @param [Symbol] pattern The match pattern
      #
      # @return [Array<Pathname>]
      def sort(path, variant, pattern = nil)
        Sorter.call(by_path(path, *pattern), variant)
      end

      # @!group Pattern Matching

      # @!attribute [r] matchers
      #   Returns a Hash mapping plural component type to a Regexp matching singular and plural
      #   forms of the type.
      #   @return [Hash{Symbol=>Regexp}]
      def matchers
        @matchers ||= ::Hash[types.map { |t| [t, Matcher.call(t)] }].freeze
      end

      # @!attribute [r] patterns
      #   Returns a Hash mapping plural component type to a pattern matching singular and plural
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

      # @!endgroup

      protected

        # Returns a list of files under directory `path` matching the given `pattern`
        #
        # @param [Pathname, String] path An **autoloadable** path
        # @param [String] pattern The match pattern
        #
        # @see https://ruby-doc.org/core-2.2.0/File.html#method-c-fnmatch-3F
        #
        # @return [Array<Pathname>]
        #
        # @raise [KeyError] if `path` invalid key or non-existent directory
        def by_path(path, pattern = NAMESPACE_PATTERN)
          fetch_or_store(path) do
            (result = find(path)) && prepare(*result)
          end&.call(pattern) || EMPTY_ARRAY
        end

        # Returns a list of files under directory `namespace` matching the given `pattern`
        #
        # @param see (#by_path)
        #
        # @return [Array<Pathname>]
        alias by_namespace by_path

        # Returns a list of files within {#target} matching `type`.
        #
        # @see https://bitbucket.org/piktur/piktur_core/src/master/spec/benchmark/pattern_matching.rb
        #   .dir_vs_pathname_glob
        #
        # @param [Symbol] type The pluralized component type
        # @param [String] pattern The match pattern
        #
        # @return [Array<String>] A list of autoloadable file paths
        def by_type(type, pattern = nil)
          return EMPTY_ARRAY unless types.include?(type)

          @fn_types ||= root_directories.map { |root| fn_get.curry[root] }

          fetch_or_store(type) do
            lambda do |type, pattern| # rubocop:disable ShadowingOuterLocalVariable
              @fn_types.flat_map { |fn| fn[type, pattern] }
            end
          end&.call(type, pattern || patterns.fetch(type) { TYPE_PATTERN % nil }) ||
            EMPTY_ARRAY
        end

        # Returns a function which, when called with a `pattern`, will return the **current** contents
        # of the `namespace` where given `pattern` matches.
        #
        # @param [Pathname] root
        # @param [Pathname] path
        #
        # @return [Proc]
        def globber(root, path)
          fn_get.curry(3)[root, Path.relative_path_from_root(path, root)]
        end

        # @param [Pathname] root The base path
        # @param [Pathname] var The variable element of the match `pattern`
        # @param [String] pattern The match pattern
        #
        # @return [Array<String>] A list of relative paths from root matching `pattern`
        def scoped_glob(root, var, pattern)
          ::Dir[pattern % var, base: root]
        end

        # @param see (#scoped_glob)
        #
        # @return [Array<String>] A list of absolute paths matching `pattern`
        def unscoped_glob(*args)
          ::Dir[args.join(::File::SEPARATOR)]
        end

        # @!group Predicates

        # @param [Pathname] path
        # @param [Pathname] target
        #
        # @return [true] if path name eq {#target} name
        def target?(path, target = self.target)
          return false if path.nil?
          Path.basename_match?(target, path) # target.basename == path.basename
        end

        # @param [Pathname] path
        #
        # @return [true] if `path` is a child of {#target}
        def child?(path)
          target?(path.parent)
        end

        # @param [Pathname] path
        #
        # @return [true] if `path` is a file and a child of {#target}
        def leaf?(path)
          path.file? && child?(path)
        end

        # @param [Pathname] path
        #
        # @return [true] if `path` is a directory and a child of {#target}
        def branch?(path)
          path.directory? && child?(path)
        end

        # Filter type directories from "concept" directories
        #
        # @param [Pathname] path
        #
        # @return [true] if path is a directory and matches {#matcher_combination}
        def type_directory?(path)
          return false if path.nil?
          path.directory? && Path.match?(path, matcher_combination)
        end

        # @!endgroup

    end

  end

end
