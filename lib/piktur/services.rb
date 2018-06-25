# frozen_string_literal: true

module Piktur

  # {Services} provides metadata and configuration to assist communication between Piktur
  # {SERVICES}.
  #
  # Basic service data is stored in `/config/services.json`.
  #
  # @note The term **"service"** -- as in **Service Oriented Architecture (SOA)** -- is used to
  #   emphasise **separation of responsibility**.
  #   A service exposes a public api that may be accessible via HTTP ie. {Application} or
  #   extends an existing interface as in {Engine} or {Library}.
  #
  # ## Developer directory structure
  #
  # Run `bin/piktur setup` to prepare development directory
  #
  # ```
  #   |-- /gem_server        # Private gem server
  #   |-- /gems              # Store forked gems
  #   |-- <project_name>     # Store common config and untracked files ie. `.env`
  #     |-- /piktur          # Piktur
  #     |-- /piktur_admin    # Piktur::Admin
  #     |-- /piktur_api      # Piktur::API
  #     |-- /piktur_blog     #
  #     |-- /piktur_client   # Piktur::Client
  #     |-- /piktur_core     # Piktur::Core
  #     |-- /piktur_docs     # Piktur::Docs
  #     |-- /piktur_security # Piktur::Security
  #     |-- /piktur_store    # Piktur::Store
  #     |-- /piktur_spec     # Piktur::Spec
  # ```
  #
  module Services

    require 'oj'

    extend ::ActiveSupport::Autoload

    autoload :Application, 'piktur/services/service'
    autoload :Engine,      'piktur/services/service'
    autoload :FileIndex
    autoload :Index
    autoload :Library,     'piktur/services/service'
    autoload :Server,      'piktur/services/servers'
    autoload :Servers
    autoload :Service

    # @see file:config/services.json
    # @return [Hash{Symbol=>Object}]
    SERVICES = ::Oj
      .load_file(::Piktur.root.join('config', 'services.json').to_s)['services']
      .deep_symbolize_keys!
      .freeze
    private_constant :SERVICES

    LIBRARIES = %i(
      piktur
      piktur_security
    ).freeze
    private_constant :LIBRARIES

    ENGINES = %i(
      piktur_core
      piktur_store
    ).freeze
    private_constant :ENGINES

    APPLICATIONS = %i(
      piktur_api
      piktur_admin
      piktur_blog
      piktur_client
      piktur_docs
      piktur_spec
    ).freeze
    private_constant :APPLICATIONS

    class << self

      # @return [Bundler::Runtime]
      def bundler_environment; ::Bundler.environment; end

      # @return [Array<Bundler::Dependency>]
      def bundler_dependencies; bundler_environment.dependencies; end

      # Returns the `Bundler::Dependency` for each Piktur gem dependency
      #
      # @return [Array<Bundler::Dependency>]
      def dependencies
        bundler_dependencies.select { |e| e.name.start_with? 'piktur' }
      end

      # Returns the `Gem::Specification` for each Piktur gem dependency
      #
      # @see https://bitbucket.org/piktur/piktur/issues/2
      #
      # @return [Hash{String=>Gem::Specification}]
      def specs
        ::Hash[dependencies.map { |dependency| [dependency.name, dependency.to_spec] }]
      end

      # Returns the gemspec for a gem NOT listed in the Gemfile
      #
      # @param [String] name The service name
      #
      # @return [Gem::Specification]
      # @return [nil] if no gemspec found
      def load_gemspec!(name)
        gemspec = Pathname('..').join(name, "#{name}.gemspec")
        gemspec = find_gemspec(name)[0] unless gemspec.exist?

        return if gemspec.nil?

        ::Bundler.load_gemspec(gemspec)
      end

      private

        # @param [String] name The service name
        #
        # @return [Array<String>]
        def find_gemspec(name)
          ::Dir.glob(
            "{gems/#{name}*/#{name}*,specifications/#{name}*}.gemspec",
            base: ENV['GEM_HOME']
          )
        end

        # @param [Array<String>] services
        #
        # @return [Array<Hash>]
        def services_data(services)
          services.zip SERVICES.values_at(*services)
        end

        # @return [Array<Hash>]
        def libraries
          services_data LIBRARIES
        end

        # @return [Array<Hash>]
        def engines
          services_data ENGINES
        end

        # @return [Array<Hash>]
        def applications
          services_data APPLICATIONS
        end

    end

  end

end
