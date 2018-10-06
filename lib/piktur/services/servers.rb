# frozen_string_literal: true

module Piktur

  module Services

    # Presents environment specific location metadata for all hosted services
    class Servers

      # @!attribute [r] all
      #   @return [Array<Services::Server>]
      attr_reader :all

      # @!attribute [r] production
      # @!attribute [r] staging
      # @!attribute [r] development
      # @return [Array<URI>]
      attr_reader :production, :staging, :development

      def initialize(services)
        @all = services.map(&:server)

        %w(production staging development).each do |env|
          instance_variable_set("@#{env}", @all.map { |server| server.uri(env) })
        end

        freeze
      end

      # @return [URI::Generic]
      def default; Server.development; end

      # @return [String]
      def inspect
        "#<Servers[#{::NAMESPACE.env}] #{send(::NAMESPACE.env).join(', ')}>"
      end

    end

    # Wrapper for {Application} server metadata
    class Server

      # @private
      #
      # @!attribute [rw] schema
      # @!attribute [rw] host
      # @!attribute [rw] subdomain
      # @return [String]
      #
      # :nocov
      class URI < ::URI::Generic

        # @!attribute [rw] subdomain
        #   @return [String]
        attr_accessor :subdomain

        # @return [Boolean]
        def http?; scheme == 'http'; end

        # @return [Boolean]
        def https?; scheme == 'https'; end
        alias ssl? https?

        # @return [void]
        def inspect; "#<URI::Generic #{self}>"; end

      end
      private_constant :URI

      # :nocov
      #
      # @param [Hash] options The URI elements
      #
      # @raise [KeyError]
      #
      # @return [URI]
      def self.uri(host:, subdomain: nil, **options)
        URI.build(host: [*subdomain, host].join('.'), **options)
          .tap { |uri| uri.subdomain = subdomain }
          .freeze
      end

      # @return [Hash]
      def self.config; Services.services; end

      # :nocov
      DEFAULT = uri(port: DEFAULT_PORT = 3000, **config.fetch(:development))
      # :nocov
      PRODUCTION = uri(config.fetch(:production))
      # :nocov
      STAGING = uri(config.fetch(:staging))
      # :nocov
      TEST = DEVELOPMENT = DEFAULT
      private_constant :DEFAULT_PORT, :DEFAULT, :PRODUCTION, :STAGING, :DEVELOPMENT, :TEST

      class << self

        # @return [URI]
        def defaults; const_get(__callee__.upcase, false); end

        # @!attribute [r] production
        # @!attribute [r] staging
        # @!attribute [r] development
        # @!attribute [r] test
        # @return [URI]
        %i(production staging development test).each { |env| alias_method env, :defaults }
        private :defaults

      end

      # @return [Regexp]
      MATCHER = case ::NAMESPACE.env
      when 'production', 'staging'
        /\A#{send(::NAMESPACE.env).scheme}:\/\/(?:.*\.)?#{send(::NAMESPACE.env).host}\Z/
      else /\A#{DEFAULT.scheme}:\/\/#{DEFAULT.host}|127[\.0]*:\d+\Z/
      end

      # @param [Services::Application] service
      #
      # @raise [URI::InvalidURIError]
      def initialize(service)
        @service = service.opts.delete(:uri)

        freeze
      end

      # @param [String, Symbol] env
      #
      # @return [URI::Generic]
      def uri(env = ::NAMESPACE.env)
        options = @service.fetch(env = env.to_sym) { return self.class.send(env) }
        self.class.uri(options.dup)
      end

      # @param [String, Symbol] env
      #
      # @return [String] the URI::Generic attribute
      def get(env = ::NAMESPACE.env); uri(env).send(__callee__); end
      %i(scheme host subdomain port userinfo path http? https?)
        .each { |aliaz| alias_method aliaz, :get }
      private :get

    end

  end

end
