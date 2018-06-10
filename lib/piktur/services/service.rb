# frozen_string_literal: true

module Piktur

  module Services

    # Canonical data object for Gem
    class Service

      # @!attribute [r]
      #   @return [String]
      attr_reader :name

      # @!attribute [r]
      #   @return [String]
      #   @return [Module] if loaded
      attr_reader :namespace

      # @!attribute [r]
      #   @return [Integer]
      attr_reader :position

      # @!attribute [r]
      #   @return [Hash]
      attr_reader :opts

      # @!attribute [r]
      #   If gem loaded, the actual path to the loaded gem
      #   @return [Pathname]
      attr_reader :path

      # @!attribute [r]
      #   Return the actual path to loaded gem
      #   @return [Pathname]

      delegate :application?, :engine?, :library?, to: :type

      # @param [String, Symbol] name
      # @param [Hash] opts
      # @param [Integer] position
      def initialize(name, position:, path: nil, namespace:, **opts)
        @name      = name.to_s
        @position  = position
        @namespace = namespace
        @opts      = opts
        self.path  = path
      end

      # @return [Module, Class]
      def loaded
        @loaded ||= constantize
      end

      # @return [Boolean]
      def loaded?
        loaded.is_a?(::Module)
      end

      # Bundler stubs the gemspec to mitigate penalty on load or whatever... Bottom line is
      # when called on the stub, `Gem.loaded_specs[name]#files` returns a file list relative to
      # `Dir.pwd` not the `Gem::Specification#gem_dir`. Furthermore, when `#gem_dir` is called on
      # the legitimate spec, it returns a
      #
      # @return [Gem::Specification]
      def gemspec
        @gemspec ||= _gemspec_path && ::Bundler.load_gemspec(_gemspec_path)
      end

      # @return [void]
      def path=(value)
        @path = if value.is_a?(String)
                  _ensure_existent_directory(value)
                elsif gemspec
                  _ensure_existent_directory(gemspec.gem_dir)
                end
      end

      # Load constant and replace {#namespace} if defined
      # @return [Module] if defined
      def constantize
        return unless namespace.is_a?(String) && Object.const_defined?(namespace)
        @namespace = Object.const_get(namespace)
      end

      # @return [Module]
      def eager_load
        namespace
      end

      # @return [String]
      def inspect
        %(<Service[#{name}] loaded=#{loaded?} root="#{path}">)
      end

      private

        # @return [Bundler::StubSpecification]
        # @return [nil] if gem not loaded
        def _stub
          ::Gem.loaded_specs[name]
        end

        # @return [String]
        # @return [nil] if gem not loaded
        def _gemspec_path
          _stub&.loaded_from
        end

        # @param [String, nil]
        #
        # @return [Pathname]
        # @return [nil] if gem not loaded
        def _ensure_existent_directory(path)
          if File.exist?(path)
            Pathname(path)
          elsif _gemspec_path
            Pathname(_gemspec_path).parent
          end
        end

    end

    # Canonical data object for a library extension
    class Library < Service

      # @return [Piktur::Support::StringInquirer]
      def type
        @type ||= ::ActiveSupport::StringInquirer.new('library')
      end

    end

    # Canonical data object for a `Rails::Engine`
    class Engine < Service

      # @!method uri
      #   @see Services::Server#uri
      #   @return [URI]
      # @!method http?
      # @!method https?
      # @return [Boolean]
      delegate :uri, :http?, :https?, to: :server

      # @return [Piktur::Support::StringInquirer]
      def type
        return @type if defined?(@type)
        *_, const = self.class.name.rpartition('::')
        @type = ::ActiveSupport::StringInquirer.new(const.downcase)
      end

      # @return [Rails::Engine]
      def loaded
        @loaded ||= railtie || false
      end

      # @return [Class]
      def railtie(const = :Engine)
        return @railtie if defined?(@railtie)
        @namespace = Support::Inflector.constantize(namespace) || namespace
        return unless @namespace.is_a?(Module)
        @railtie = Support::Inflector.constantize(const, @namespace)
      end

      # @return [Services::Server]
      def server
        @server ||= Server.new(self)
      end

      # @return [Array]
      def eager_load
        [namespace, *railtie]
      end

    end

    # Canonical data object for a `Rack` application
    class Application < Engine

      # def engine?; true; end

      # @return [Class]
      def railtie
        super(:Application)
      end

    end

  end

end
