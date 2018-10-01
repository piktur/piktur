# frozen_string_literal: true

module Piktur

  module Loader

    # A Loader manages a {Filters#target} directory. The relative directory name is passed to the
    # constructor and becomes the base scope for all future queries of the file system. The
    #
    # When querying the file system, the Loader will scan all {Filters#root_directories} in which
    # the `target` exists.
    #
    # The query itself (a `Proc`) is cached, so that when called, the result (a list of files)
    # is always current. The file paths are relative to the `target` and,
    # if the path is **autoloadable**, and the constants within them cleared, can be reloaded.
    #
    # In non-production environments, when the application is reloaded, any new constant
    # definitions can be **automatically** registered under the parent namespace or with a
    # `Dry::Container` instance.
    #
    # @see https://bitbucket.org/piktur/piktur_core/src/master/lib/piktur/concepts/dsl.rb
    #
    # ## Config
    #
    # At present, only `ActiveSupport::Dependencies` is integated. To implement a different strategy
    # define your constant, include {Base} and assign the `:<loader_name>` to
    # {Config.loader} instance. The defintion should be filed under
    # `/lib/piktur/setup/loader/strategies/<loader_name>.rb`. An instance will be assigned to the
    # {Config} object. The instance should be `#call`able.
    #
    # Any **autoloadable** directory can be used, though typically, the configured
    # {Config.components_directory} is used. The list of component {Filters#types} is also
    # configurable, use {Config.component_types}, the loader will references types in the
    # form specified by {Config.nouns}.
    #
    # {include:Load}
    #
    # {include:Filters}
    #
    # {include:Filter}
    #
    # {include:Store}
    #
    # {include:Index}
    #
    # @abstract
    module Base

      # @param [Module] base
      # @return [void]
      def self.included(base)
        base.extend  self::ClassMethods
        base.include self::InstanceMethods
        base.include Loader::Pathname
        base.include Loader::Store
        base.include Loader::Predicates
        # base.include Loader::Index
        base.include Loader::Filters
        base.prepend Loader::Load
      end

      # :nodoc
      module ClassMethods

        # @!attribute [rw] default_proc
        #   @return [Proc] The block to execute when loading a file
        attr_accessor :default_proc

        # @!attribute [rw] use_relative
        #   @return [Boolean] if true paths will be scoped to {Filters#target}
        attr_accessor :use_relative

        # :nodoc
        def new(*)
          getter = Loader.method(use_relative ? :scoped_glob : :unscoped_glob).to_proc
          super.instance_exec do
            self.fn = ::Hash.new { |h, k| h[k] = Loader.const_get(k).new(self) }
            fn[:set] = method(:_store_path).to_proc
            fn[:get] = getter
            self
          end
        end

      end

      # :nodoc
      module InstanceMethods

        # @!attribute [r] booted
        #   @return [Boolean] True after the first call to {#load!}
        attr_reader :booted
        alias booted? booted

        # @!attribute [r] fn
        #   A store for `callable` functions and {Filter} instances.
        #   @return [Hash{Symbol=>Object}]
        attr_accessor :fn

        # @!attribute [r] loaded
        #   @return [Set<String, Symbol>] A list of loaded namespaces
        attr_reader :loaded

        def initialize
          @loaded = ::Set.new
        end

        # :nodoc
        def call(*); raise ::NotImplementedError; end

        # @return [Dry::Configurable]
        def config; ::NAMESPACE.config.loader; end

        # Returns the segment of a file path corresponding to the constant defined within it.
        #
        # @note The path should begin with or be relative to {#target}
        #
        # @param [String] path The file path
        # @option options [Regexp] :namespace (false)
        # @option options [Regexp] :suffix (".rb") If matched, the `suffix` is removed.
        #
        # @return [String]
        # @return [String] if `namespace` true, the directory name.
        def to_constant_path(path, root = nil, namespace: false, suffix: /\.rb$/)
          right_of(path, target(root), relative: true).tap do |str|
            return str.rpartition(::File::SEPARATOR)[0] if namespace
            str.sub!(suffix, EMPTY_STRING)
          end
        end

        # @return [String]
        def inspect
          "<Loader target=\"#{target}\" booted=#{booted? || false} count=#{cache.size}>"
        end

        # @return [void]
        def pretty_print(pp); pp.text inspect; end

        protected

          # @param [Array<Pathname>] paths The paths to load
          #
          # @return [void]
          def load(paths)
            throw(:abort) if paths.blank?
            paths.each { |path| yield path }
          end

          # @param [String] id
          #
          # @return [Boolean]
          def loaded?(id); loaded.member?(id); end

          # @return [true]
          def booted!; @booted = true; end

          # @param [Symbol] paths The loaded paths
          #
          # @return [void]
          def debug(paths)
            return unless config.debug
            ::NAMESPACE.logger.info "Loaded:\n#{paths.map { |p| "  - #{p}" }.join("\n")}"
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
            types&.include?(method_name) || super
          end

      end

    end

  end

end
