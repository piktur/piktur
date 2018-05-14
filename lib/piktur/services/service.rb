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

      delegate :application?, :engine?, :library?, to: :type

      # @param [String, Symbol] name
      # @param [Hash] opts
      # @param [Integer] position
      def initialize(name, position:, path: nil, namespace:, **opts)
        @name      = name.to_s
        @position  = position
        @path      = path
        @namespace = namespace
        @opts      = opts
      end

      # @note `defined?(namespace)` will return false positive if `namespace` nil or a String.
      # @return [Module, Class]
      def loaded
        @loaded ||= constantize
      end

      # @return [Boolean]
      def loaded?
        loaded.is_a?(Module)
      end

      # @return [Gem::Specification]
      def gemspec
        ::Gem.loaded_specs[name]
      end

      # Return path to gem installation
      # @note There may be cases where the service is not a gem. The path cannot be inferred and
      #   has to be declared explicitly, as in Test::Dummy application.
      # @return [Pathname, nil]
      def path
        @path = if gemspec
                  Pathname(gemspec.gem_dir)
                elsif @path.is_a?(Array)
                  root, path = @path
                  Pathname(::Gem.loaded_specs[root].gem_dir).join(path)
                elsif @path.is_a?(String)
                  Pathname(path)
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
