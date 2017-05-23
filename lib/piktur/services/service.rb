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
      # @param [Integer] position
      # @param [Hash] opts
      def initialize(name, position, **opts)
        @name      = name.to_s
        @position  = position
        @namespace = opts.delete(:namespace)
        @opts      = opts
      end

      # @note `defined?(namespace)` will return false positive if `namespace` nil or a String.
      # @return [Boolean]
      def loaded?
        @loaded ||= constantize.is_a?(Module)
      end

      # @return [Gem::Specification]
      def gemspec
        ::Gem.loaded_specs[name]
      end

      # Return path to gem installation
      # @return [Pathname]
      def path
        Pathname(gemspec.gem_dir)
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

      # @return [ActiveSupport::StringInquirer]
      def type
        @type ||= 'library'.inquiry
      end

    end

    # Canonical data object for a `Rails::Engine`
    class Engine < Service

      # @return [ActiveSupport::StringInquirer]
      def type
        @type ||= 'engine'.inquiry
      end

      # @return [Class]
      def railtie(const = :Engine)
        return @railtie if @railtie
        return unless loaded?
        @railtie = namespace.const_get(const) if namespace.const_defined?(const)
      end

      # @return [Array]
      def eager_load
        [namespace, *railtie]
      end

    end

    # Canonical data object for a `Rack` application
    class Application < Engine

      # @!method uri
      #   @see Services::Server#uri
      #   @return [URI]
      # @!method http?
      # @!method https?
      # @return [Boolean]
      delegate :uri, :http?, :https?, to: :server

      # @return [ActiveSupport::StringInquirer]
      def type
        @type ||= 'application'.inquiry
      end

      # @return [Services::Server]
      def server
        @server ||= Server.new(self)
      end

      # @return [Class]
      def railtie
        super(:Application)
      end

    end

  end

end
