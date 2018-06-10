# frozen_string_literal: true

module Piktur

  module Services

    # Group files by component type. Component types are declared explicitly or inferred from
    # directories under {#target}.
    #
    # It is expected that:
    #   * files located under `app/models`
    #   * or files named `model.rb`
    # define a "model" and the definition is assigned to a constant matching the file or directory
    # name.
    class FileIndex

      # @param [Service] service
      # @param [Array<String>] types
      Files = Struct.new(:service, :types, :matchers) do
        # @!attribute [r] types
        #   A list of component types found in {#target} sub directories
        #   @return [Array<Symbol, String>]

        # @!attribute [r] matchers
        #   A list of component types found in {#target} sub directories
        #   @return [Hash<Symbol, String>]

        def name; service.name; end
        def root; service.path; end
        def files; service.gemspec.files; end

        # @yieldparam [String] file
        #
        # @return [Enumerator]
        def each(&block); files.each(&block); end

        # @return [Array]
        def to_a; files; end

        # @param [Symbol] type The component type in plural form
        #
        # @return [Array<String>]
        def by_type(type)
          files.select { |f| f[matchers[type]] } # .map { |f| [root, f] }
        end

        # @return [String]
        # redefine_method(:inspect) do
        #   %(<FileIndex[#{name}] root="#{root}">)
        # end
        # alias_method :to_s, :inspect
      end
      private_constant :Files

      # @!attribute [r] services
      #   @return [Array<Services::Service>] A list of all loaded services
      attr_reader :services

      # @!attribute [r] files
      #   A Hash mapping the service to a Files object
      #   @return [Hash{String=>Files}]
      attr_reader :files

      # @!attribute [r] target
      #   The relative path to the application directory. Default 'app'
      #   @return [String]
      attr_reader :target

      # @!attribute [r] paths
      #   @return [Array<Pathname>] A list of root paths
      attr_reader :paths

      # @param [Array<Services::Service>] services
      #
      # @option options [Array<Symbol, String>] :component_types
      # @option options [String] :target (app)
      def initialize(services, component_types:, target: 'app')
        @services          = services
        @target            = target.freeze
        self.type_matchers = component_types
        self.type_matcher  = component_types
        @paths             = services.map(&:path).compact
        @files             = wrap_files
        freeze
      end

      # @!attribute [r] type_matcher
      #   @return [Regexp]
      attr_reader :type_matcher

      # @!attribute [r] type_matchers
      #   Returns a Hash mapping plural component type to a Regexp matching singular and plural
      #   forms of the type.
      #   @return [Hash{Symbol=>Regexp}]
      attr_reader :type_matchers

      # @param [component_types] A list of expected comonent types
      #
      # @return [void]
      def type_matcher=(component_types)
        @type_matcher = /.*(#{Regexp.union(type_matchers.values)})/ # /#{target}\/([\w_]+)\//
      end

      # @param [component_types] A list of expected comonent types
      #
      # @return [Hash{Symbol=>Regexp}]
      def type_matchers=(component_types)
        @type_matchers ||= component_types.each_with_object({}) do |type, h|
          a = ::Inflector.singularize(type)
          b = ::Inflector.pluralize(type)
          h[b.to_sym] = /(#{a}|#{b})/ # /(#{a}|#{a}\/.*|#{b}|#{b}\/.*)\.rb/
        end.freeze
      end

      # @!attribute [r] types
      #   @return [Set<String>]
      def types
        return @types if defined?(@types)
        set = Set.new
        services.each do |service|
          next unless service.gemspec
          set.merge(extract_component_types(filter_target_entries(service.gemspec.files)))
        end
        @types = set
      end

      # @overload search('app/models')
      #   Returns all files for loaded services under `[service]/app/models`

      # @overload search('config/locales', '**/*.{rb,yml}')

      # @deprecated Potentially expensive and unnecessary.
      #
      # @param [String] args
      #
      # @return [Array<String>]
      def search(*args)
        ::Piktur::Deprecation[__method__, __FILE__, __LINE__]
        Dir[*paths_glob(*args)]
      end

      # @param [String] type
      #
      # @return [Array<String>]
      def by_type(type = __callee__)
        arr = []
        files.each_value do |object|
          object.each do |f|
            next unless f[/^#{target}.*#{type_matchers[type]}(?!\/concerns)/]
            f = ::File.join(object.root, f)
            arr << f if ::File.file?(f)
          end
        end
        arr.sort!
      end
      alias models by_type

      # @return [Array<String>]
      def locales
        ::Rails.configuration.i18n.load_path
      end

      # @return [String]
      def inspect
        "<FileIndex #{services.map { |e| %(#{e.name}="#{e.path}") }.join(' ')}>"
      end

      private

        # @return [Hash{String=>Files}]
        def wrap_files
          files = {}
          services.each do |service|
            next unless service.gemspec
            service.path && files[service.name] = Files.new(service, types, type_matchers)
          end
          files
        end

        # @param [<Array<String>>]
        #
        # @return [Array<String>]
        def filter_target_entries(files)
          files.select { |f| f.start_with?(target) }
        end

        # Extract types from entries under {#target}
        #
        # @return [Array<String>]
        def extract_component_types(files)
          files.map { |f| f =~ type_matcher && $1 }.compact.uniq
        end

        # Return an array of paths where `dir` exists -- relative to railtie root, and
        # appends `glob` pattern to each.
        #
        # @param [String] dir A relative path from root
        # @param [String] glob A glob expression
        #
        # @return [Array<Pathname>] absolute path per railtie where `dir` exists
        # @return [Array<Pathname>] if `glob` given, appends `glob` pattern to absolute path
        def paths_glob(dir, glob = '**/*.rb')
          paths.map { |path| path.join(dir, *glob) }
        end

        # @raise [NoMethodError] if non existent component type
        #
        # @return [void]
        def method_missing(method_name, *args)
          return super unless respond_to_missing?(method_name)
          by_type(method_name)
        end

        # @return [Boolean]
        def respond_to_missing?(method_name, include_private = false)
          type_matchers.include?(method_name) || super
        end

    end

  end

end
