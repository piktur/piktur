# frozen_string_literal: true

module Piktur

  module Services

    # Canonical data object for Gem
    class Service

      # @!attribute [r] name
      #   @return [String]
      attr_reader :name

      # @!attribute [r] namespace
      #   @return [String]
      #   @return [Module] if loaded
      attr_reader :namespace

      # @!attribute [r] position
      #   @return [Integer]
      attr_reader :position

      # @!attribute [r] opts
      #   @return [Hash]
      attr_reader :opts

      # @!attribute [r] path
      #   If gem loaded, the actual path to the loaded gem
      #   @return [Pathname]
      attr_reader :path
      alias root path

      delegate :application?, :engine?, :library?, to: :type

      # @param [String, Symbol] name
      # @param [Hash] opts
      # @param [Integer] position
      def initialize(name, position:, path: nil, namespace:, **opts)
        @name      = name.to_s
        @position  = position
        @namespace = Support::Inflector.constantize(namespace, ::Object) || namespace
        @opts      = opts
        self.path  = path
      end

      # @!attribute [r] loaded
      #   @return [Module, Class]
      alias loaded namespace

      # @!attribute [r] eager_load
      #   @return [Module, Class]
      alias eager_load namespace

      # @return [Boolean]
      def loaded?
        loaded.is_a?(::Module)
      end

      # @see Services.specs
      #
      # @return [Gem::Specification]
      def gemspec
        @gemspec ||= Services.specs.fetch(name) do
          Services.load_gemspec!(name) unless ::NAMESPACE.env.production?
        end
      end

      # Returns the directory from which the service was loaded.
      #
      # @param [String] path The path specified in `piktur/config/services.json`, if any.
      #
      # @return [void]
      def path=(path)
        [
          *path,                 # A path specified in `piktur/config/services.json`.
          *gemspec&.gem_dir,     # May be incorrect if remote gem source.
          *gemspec&.loaded_from, # The gemspec path -- only necessary if remote source.
          "../#{name}"           # Or try the local directory.
        ].each { |candidate| break(path = candidate) if ::File.exist?(candidate) }

        @path = Pathname(path).instance_eval { (file? ? parent : self).realpath }
      end

      # @return [Boolean]
      def itself?
        path == ::Pathname.pwd
      end

      # @return [String]
      def inspect
        %(#<Service[#{name}] loaded=#{loaded?} root="#{path}">)
      end

      # @return [void]
      def pretty_print(pp); pp.text inspect; end

    end

    # Canonical data object for a library extension
    class Library < Service

      # @return [ActiveSupport::StringInquirer]
      def type
        @type ||= ::ActiveSupport::StringInquirer.new('library')
      end

    end

    # Canonical data object for a `Rails::Engine`
    class Engine < Service

      # @!method uri
      #   @see Services::Server#uri
      #   @return [URI]
      delegate :uri, to: :server

      # @!method http?
      # @!method https?
      # @return [Boolean]
      delegate :http?, :https?, to: :server

      # @return [ActiveSupport::StringInquirer]
      def type
        return @type if defined?(@type)

        *, const = self.class.name.rpartition('::')
        @type = ::ActiveSupport::StringInquirer.new(const.downcase)
      end

      # @return [Rails::Engine]
      def loaded
        railtie || false
      end

      # @return [Class]
      def railtie(const = :Engine)
        namespace && Support::Inflector.constantize(const, namespace)
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
