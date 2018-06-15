# frozen_string_literal: true

module Piktur

  module Services

    # Group files by component type. Component types **SHOULD** be declared explicitly.
    # The file list is based on those exposed through the `.gemsepec`. **DO NOT** declare absolute
    # paths in the `.gemspec`.
    #
    # It is expected that:
    #   * files located under `app/models`
    #   * or files named `model.rb`
    # define a "model" and the definition is assigned to a constant matching the file or directory
    # name.
    class FileIndex

      # @!attribute [r] types
      #   A list of component types found in {#target} sub directories
      #   @return [Array<Symbol, String>]
      #
      # @!attribute [r] matchers
      #   A list of component types found in {#target} sub directories
      #   @return [Hash<Symbol, String>]
      #
      # @param [Service] service
      # @param [Hash{Symbol=>Regexp}] matchers
      Files = Struct.new(:paths, :files) do # :types
        # Move to Loader
        def cache
          @cache ||= { target: nil, types: {}, namespaces: {} }
        end

        # Move to Loader
        # @param [Symbol] type The component type in plural form
        #
        # @return [Array<File>]
        def by_type(type)
          fetch_or_store(:types, type) do
            cache[:types][type] = filter_target_entries.select { |f| f.type == type }
          end
        end

        # Move to Loader
        # @param [String] mod The component namespace
        #
        # @return [Array<File>]
        def by_namespace(mod)
          fetch_or_store(:namespaces, mod) do
            cache[:namespaces][mod] = filter_target_entries.select { |f|
              f.autoload.start_with?(mod)
            }
          end
        end

        # @yieldparam [String] file
        #
        # @return [Enumerator]
        def each(&block); files.each(&block); end

        # @yieldparam [String] file
        #
        # @return [Enumerator]
        def select(&block); files.select(&block); end

        # @!method to_a
        # @!method all
        # @return [Array]
        alias_method :to_a, :files
        alias_method :all, :files

        # @return [String]
        def inspect
          "<FileIndex count=#{files.size}>"
        end

        # @return [void]
        def pretty_print(pp); pp.text inspect; end

        private

          # Move to Loader
          # @return [Pathname]
          def self.target
            ::Piktur.components_dir
          end

          # Move to Loader
          # @return [Integer]
          def target.len
            @_len ||= @path.size
          end

          # Move to Loader
          def target.to_s
            @path
          end

          # Move to Loader
          # @param [<Array<String>>]
          #
          # @return [Array<String>]
          def filter_target_entries
            cache[:target] ||= select { |f| f.relative.start_with?(self.class.target.to_s) }
          end

          # Move to Loader
          # @param [Symbol, Object] path
          #
          # @return [void]
          def fetch_or_store(namespace, key, &block)
            cache[namespace].fetch(key, &block)
          end
      end
      private_constant :Files

      # This is all good but we're losing the line of responsibility
      # A lot of this logic belongs with the loader. Only the loader should care about
      # the components directory, move all this matching and sorting logic to the Loader
      # File Index is just that, a list of all files. The loader can select take the reigns from there.

      Loader = Class.new do
        # Transfer all methods and logic marked "Move to Loader"
      end

      Matchable = Module.new do
        def abc; self; end
      end

      Pathname = Class.new(Pathname) do
        def self.new(path)
          super.instance_exec do
            @path.extend(Matchable)
          end
        end

        def expand_path()
        def to_s
          @path
        end

        def inspect; super; end


      end

      # @return [Struct]
      Pathname = ::Struct.new(:service, :absolute, :relative, :type, :namepsace, :i) do
        # @return [String]
        def name; service[0]; end

        # @return [Pathname]
        def root; service[1]; end

        # @return [Pathname]
        def target
          ::Piktur.components_dir
        end

        # Move to Loader
        # @return [String]
        def autoload
          @autoload ||= relative[(::Piktur.components_dir.len + 1)..-1]
        end

        # Use Pathname for this
        # @return [String]
        def absolute
          self[1] ||= "#{root}#{::File::SEPARATOR}#{relative}"
        end

        # Move to Loader
        # @return [Symbol]
        def type
          return self[3] if self[3].present?
          ::Piktur.files.type_matchers.each do |type, matcher|
            break(self[3] = type) if relative.index(matcher) # self[5] =
          end
          self[3] ||= Undefined
        end

        # # @param [Symbol] other
        # #
        # # @return [Boolean]
        # def match_type(other)
        #   type == other
        # end

        # @return [String]
        # def namespace
        #   return unless type && i
        #   self[4] ||= relative[(target.len + 1)...(i - 1)]
        # end

        # # @param [String] other
        # #
        # # @return [Boolean]
        # def match_namepsace(other)
        #   namespace == other
        # end

        # Returns the relative path. Presuming each gem's component directory is registered with
        # ActiveSupport::Dependencies.autoload_paths, the relative path should be loadable.
        #
        # @example
        #   relative_path = Files.all.first.to_s # => 'app/policies/base.rb'
        #   require_dependency relative_path     # => true
        #
        # @return [String]
        # def to_s
        #   relative
        # end

        # @return [String]
        def inspect
          "<Pathname[\"#{relative}\"] source=\"#{name}\">"
        end

        # @return [void]
        def pretty_print(pp); pp.text inspect; end
      end
      private_constant :File

      # No need to store services on the instance just pass them to _build_file_index as an arg
      #
      # @!attribute [r] services
      #   @return [Array<Services::Service>] A list of all loaded services
      attr_reader :services

      # @!attribute [r] files
      #   A Hash mapping the service to a Files object
      #   @return [Hash{String=>Files}]
      attr_reader :files

      # @!attribute [r] paths
      #   @return [Array<Pathname>] A list of root paths
      attr_reader :paths

      # Move to Loader
      #
      # @!attribute [r] target
      #   The relative path to the application directory. Default 'app'
      #   @return [String]
      attr_reader :target

      # Move to Loader
      #
      # @!attribute [r] type_matcher
      #   @return [Regexp]
      attr_reader :type_matcher

      # Move to Loader
      #
      # @!attribute [r] type_matchers
      #   Returns a Hash mapping plural component type to a Regexp matching singular and plural
      #   forms of the type.
      #   @return [Hash{Symbol=>Regexp}]
      attr_reader :type_matchers

      # @param [Array<Services::Service>] services
      #
      # @option options [String] :components_dir (nil)
      # @option options [Array<Symbol, String>] :component_types (nil)
      # @option options [String] :target (app)
      def initialize(services,
        components_dir: nil, # Move to Loader
        component_types: nil, # Move to Loader
        target: 'app' # Move to Loader
      )
        @services = services
        _build_file_index
        freeze






        # Move to Loader
        @target   = target.freeze

        # Move to Loader
        if component_types
          @component_types = component_types.map { |type| ::Inflector.pluralize(type).to_sym }
          _build_matchers
        end

        # Move to Loader
        _build_cache


      end

      # Move to Loader
      #
      # Returns a list of files within {#target} matching `type`.
      #
      # @param [String, Symbol] type The pluralized component type
      # @param [Boolean] relative
      #
      # @return [Array<String>] if `relative` false a list of absolute paths
      # @return [Array<String>] if `relative` true a list of relative paths
      def by_type(type = __callee__, relative: false)
        relative ? fetch_or_store(type).map(&:second) : fetch_or_store(type).map(&:first)
      end

      # Move to Loader
      #
      # @!method [r] models
      # @!method [r] policies
      # @!method [r] repositories
      # @!method [r] schemas
      # @!method [r] transactions
      # @return [Array<String>]
      %i(models policies repositories schemas transactions)
        .each { |aliaz| alias_method aliaz, :by_type }

      # Remove
      #
      # @!attribute [r] types
      #   @deprecated Declare component types explicitly
      #   @return [Set<String>]
      def types
        EMPTY_SET

        # return @types if defined?(@types)
        # set = Set.new
        # services.each do |service|
        #   next unless service.gemspec
        #   set.merge(extract_component_types(filter_target_entries(service.gemspec.files)))
        # end
        # @types = set
      end

      # Move to Loader
      #
      # @example Regexp is slower than String#slice
      #   NAMESPACE_MATCHERS = {}.tap do |h|
      #     %i(model schema).each do |component_type|
      #       h[component_type] = /#{::Piktur.components_dir}\/(.*)\/#{component_type}\.rb/
      #     end
      #     h.freeze
      #   end
      # @see https://bitbucket.org/piktur/piktur_core/src/master/spec/benchmarks/string_manipulation.rb
      #
      # @example
      #   path     = 'app/concepts/users/model.rb'
      #   root     = 'app/concepts'
      #   basename = 'model.rb'
      #   extract_namespace(path, basename) # => 'users'
      #
      # @param [String] input
      # @param [String, Pathname] root
      # @param [String, Pathname] basename
      #
      # @return [String] Returns the characters between `root` and `basename`
      def extract_namespace(input, root, basename)
        input.to_s[(root.to_s.size + 1)...-(basename.to_s.size + 1)]
      end

      # Move to Loader
      #
      # @return [Array<String>]
      def locales
        ::Rails.configuration.i18n.load_path
      end

      # @return [String]
      def inspect
        "<FileIndex services=[#{services.map { |e| "\"#{e.name}\"" }.join(', ')}] count=#{files.files.size}>" # rubocop:disable LineLength
      end

      private

        # Move to Loader
        # @return [Array]
        def fetch_or_store(type)
          @cache[type] ||= _by_type(type, relative: true)
        end

        # Move to Loader
        # @return [void]
        def _build_cache
          @cache = @component_types.present? ? ::Struct.new(*@component_types).allocate : {}
        end

        # Move to Loader
        # @return [void]
        def _build_matchers
          matchers = Support::FileMatcher.call(*@component_types)
          @type_matcher  = matchers.pop # /#{target}\/([\w_]+)\//
          @type_matchers = @component_types
            .each_with_object({}) { |type, h| h[type] = matchers.shift }
            .freeze
        end

        # @todo Remove
        #
        #
        # Returns a list of files within {#target} matching `type`.
        #
        # @param [String, Symbol] type The pluralized component type
        # @param [Boolean] relative
        #
        # @return [Array<String>] if `relative` false a list of absolute paths
        # @return [Array<Array<String, String>>] if `relative` true a list containing the relative
        #   and absolute paths for each file.
        def _by_type(type = __callee__, relative: false)
          arr = []
          files.each_value do |object|
            object
              .select { |relative_path| relative_path.start_with?(target) }
              .each do |relative_path|


                # /^#{target}.*#{type_matchers[type]}(?!\/concerns)/
                # /^#{target}.*#{type_matchers[type]}/
                next unless (i = relative_path.index(type_matchers[type]))
                absolute_path = ::File.join(object.root, relative_path)
                arr << File.new(absolute_path, relative_path, type, i)


              end
          end
          arr # arr.sort!
        end

        # Returns a {Files} object containing all files listed in the loaded gem specs.
        #
        # @return [Files]
        def _build_file_index
          obj       = Files.allocate
          obj.paths = services.map(&:path).compact
          obj.files = services.flat_map do |service|
            service.gemspec.files.map do |f|
              entry          = Pathname.allocate
              entry.service  = [service.name, service.path]
              entry.relative = f
              entry
            end
          end

          @files = obj
        end

        # @todo Remove
        #
        # Extract types from entries under {#target}
        #
        # @return [Array<String>]
        def extract_component_types(files)
          files.map { |f| $1.chop if f =~ type_matcher }.compact.uniq
        end

        # Move to Loader
        #
        # @raise [NoMethodError] if non existent component type
        #
        # @return [void]
        def method_missing(method_name, *args)
          return super unless respond_to_missing?(method_name)
          fetch_or_store(method_name).map(&:first)
        end

        # Move to Loader
        #
        # @return [Boolean]
        def respond_to_missing?(method_name, include_private = false)
          @component_types.include?(method_name) || super
        end

    end

  end

end
