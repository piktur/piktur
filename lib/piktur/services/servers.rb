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
      # @return [Array<String>]
      attr_reader :production, :staging, :development

      def initialize(services)
        @all = services.map(&:server)
        %w(production staging development).each do |env|
          instance_variable_set("@#{env}", @all.map { |server| server.uri(env) })
        end
        freeze
      end

      # @return [Struct]
      def domain
        Server.send(::Piktur.env)
      end

    end

    # Presents environment specific remote location data for hosted {Application}s
    class Server

      require 'active_support/core_ext/hash/indifferent_access'

      # @private
      # :nocov
      Defaults = Struct.new(:scheme, :host) do
        def https?
          scheme == 'https'
        end
        alias_method :ssl?, :https?
      end
      private_constant :Defaults

      # :nocov
      # @raise [KeyError]
      # @return [Defaults]
      def self.defaults_for(env)
        Defaults.new(*Services.const_get(:SERVICES).fetch(env).values_at(:scheme, :host)).freeze
      end
      private_class_method :defaults_for

      # :nocov
      DEFAULTS    = defaults_for(:development)
      # :nocov
      PRODUCTION  = defaults_for(:production)
      # :nocov
      STAGING     = defaults_for(:staging)
      # :nocov
      DEVELOPMENT = DEFAULTS
      # :nocov
      TEST        = DEFAULTS
      private_constant :DEFAULTS, :PRODUCTION, :STAGING, :DEVELOPMENT, :TEST

      # @!method defaults
      # @!method production
      # @!method staging
      # @!method development
      # @!method test
      # @!scope class
      # @return [Defaults]
      %w(defaults production staging development test).each do |e|
        val = const_get(e.upcase, false)
        define_singleton_method(e) { val }
      end

      # @return [Regexp]
      def self.matcher
        case ::Piktur.env
        when 'production', 'staging'
          /\A#{send(::Piktur.env).scheme}:\/\/(?:.*\.)?#{send(::Piktur.env).host}\Z/
        else /\A#{defaults.scheme}:\/\/localhost|127[\.0]*:\d+\Z/
        end
      end

      delegate :env, to: :Piktur

      delegate :http?, :https?, to: :scheme

      # @param [Services::Application] service
      # @raise [URI::InvalidURIError]
      def initialize(service)
        @uri = service.opts.delete(:uri)
          .transform_values { |uri| URI.parse(uri) if uri.present? }
          .with_indifferent_access
        freeze
      end

      # @param [String, Symbol] env
      # @return [URI::Generic]
      def uri(env = self.env)
        @uri[env] ||= URI('')
      end

      # @param [String, Symbol] env
      # @return [ActiveSupport::StringInquirer]
      def scheme(env = self.env)
        ::ActiveSupport::StringInquirer.new(uri(env).scheme || '')
      end

      # @param [String, Symbol] env
      # @return [String]
      def host(env = self.env)
        uri(env)&.host
      end

      # @see http://stackoverflow.com/a/5196844 Subdomain matcher
      # @param [String, Symbol] env
      # @return [String] if match
      def subdomain(env = self.env)
        host(env) =~ /\A([a-z\d]+(?:[-_][a-z\d]+)*).#{self.class.send(env).host}\Z/ && $1
      end

      # @param [String, Symbol] env
      # @return [Integer]
      def port(env = self.env)
        uri(env)&.port
      end

      # @param [String, Symbol] env
      # @return [String]
      def userinfo(env = self.env)
        uri(env)&.userinfo
      end

      # @param [String, Symbol] env
      # @return [String]
      def path(env = self.env)
        uri(env)&.path
      end

    end

  end

end
