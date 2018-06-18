# frozen_string_literal: true

module Piktur

  module Loader

    # @abstract
    module Base

      # @param [Module] base
      # @return [void]
      def self.included(base)
        base.extend  self::ClassMethods
        base.include Support::Pathname
        base.include self::InstanceMethods
        base.include Loader::Store
        base.include Loader::Filter
        base.include Loader::Load
      end

      # :nodoc
      module ClassMethods

        # @!attribute [rw] default_proc
        #   @return [Proc] The block to execute when loading a file
        attr_accessor :default_proc

        # @!attribute [rw] use_relative
        #   @return [Boolean] if true paths will be scoped to {Filter#target}
        attr_accessor :use_relative

      end

      # :nodoc
      module InstanceMethods

        # @!attribute [r] loaded
        #   @return [Set<String, Symbol>] A list of loaded namespaces
        attr_reader :loaded

        # @!attribute [r] booted
        #   @return [Boolean] True after the first call to {#load!}
        attr_reader :booted
        alias booted? booted

        def initialize(*)
          @types = ::Piktur::Concepts::COMPONENTS
            .map { |type| ::Inflector.pluralize(type).to_sym }
          @loaded = ::Set.new
        end

        # :nodoc
        # def call(*)
        #   raise ::NotImplementedError
        # end

        # @return [Dry::Configurable]
        def config; ::Piktur.config.loader; end

        # @return [String]
        def inspect
          "<Loader booted=#{booted? || false} count=#{cache.size}>"
        end

        # @return [void]
        def pretty_print(pp); pp.text inspect; end

        protected

          # Prepare the value to be stored
          #
          # @see Filter#globber
          #
          # @param [Pathname] root The service's root path
          # @param [Pathname] path The absolute path to the directory
          # @param [Pathname] fn  getter function to cache
          #
          # @raise [UncaughtThrowError]
          #
          # @return [Proc]
          def prepare(root, path, &fn)
            # Disregard if `path` is a {#leaf?}
            throw(:abort) if path.nil? || leaf?(path)

            # Return the given block, this value will be cached
            return fn if fn

            if path.directory?
              globber(root, path)
            else
              # The globber is scoped to parent directory so that, when reloading, any **modified**
              # file in the changes payload could be used to retrieve the contents of the parent
              # directory.
              globber(root, path.parent)
            end
          end

          # @see #globber
          # @see https://bitbucket.org/piktur/piktur_core/src/master/spec/benchmark/pattern_matching.rb
          #   .dir_vs_pathname_glob
          #
          # @return [Proc]
          def fn_get
            @fn_get ||= method(self.class.use_relative ? :scoped_glob : :unscoped_glob).to_proc
          end

          # @see Store#_store_path
          #
          # @return [Proc]
          def fn_set
            @fn_set ||= method(:_store_path).to_proc
          end

          # :nodoc
          # def load!(*)
          #   raise ::NotImplementedError
          # end

          # @return [true]
          def booted!; @booted = true; end

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
          def loaded?(id)
            loaded.member?(id)
          end

          # @param [Symbol] paths The loaded paths
          #
          # @return [void]
          def debug(paths)
            return unless config.debug
            ::Piktur.logger.info "Loaded: #{paths.map { |p| "  - #{p}" }.join("\n")}"
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
            types.include?(method_name) || super
          end

      end

    end

  end

end
