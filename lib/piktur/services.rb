# frozen_string_literal: true

module Piktur

  # {Services} exposes functionality to **boot** and communicate with hosted application modules.
  #
  # @note The term **"service"** -- as in **Service Oriented Architecture (SOA)** -- is used to
  #   emphasise **separation of responsibility**.
  #
  #   A service exposes a public api that may be accessible via HTTP ie. {Application} or
  #   extends an existing interface as in {Engine} or {Library}.
  #
  # @example Configure services
  #   /config/services.json
  #   {
  #     "applications": [<gem_name>],
  #     "libraries": [<gem_name>],
  #     "engines": [<gem_name>],
  #     "services": {
  #       <environment>: {
  #         "host": String,
  #         "scheme": String[https|http]
  #       },
  #       <gem_name>: {
  #         "namespace": String
  #       },
  #       <gem_name>: {
  #         "namespace": String,
  #         "uri": {
  #           <environment>: {
  #             "host": String,
  #             "subdomain": String,
  #             "port": Integer,
  #             "scheme": String[https|http]
  #           }
  #         }
  #       }
  #     }
  #   }
  #
  #   module Namespace
  #     ::Piktur.install(self, :Services) # Install Piktur utilities
  #
  #     Services.define(
  #       ::Dir.pwd,
  #       applications: %i(app),
  #       engines:      %i(engine),
  #       libraries:    %i(lib)
  #     )
  #   end
  module Services

    extend ::ActiveSupport::Autoload

    autoload :Application, 'piktur/services/service'
    autoload :Engine, 'piktur/services/service'
    autoload :FileIndex
    autoload :Index
    autoload :Library, 'piktur/services/service'
    autoload :Server, 'piktur/services/servers'
    autoload :Servers
    autoload :Service

    # @return [URI]
    BITBUCKET_API = URI('https://api.bitbucket.org/2.0/')

    # @return [String] The relative path at which services metadata SHOULD BE located
    SERVICES_FILE = 'config/services.json'

    class << self

      # Parse service gem metadata and assign to constants
      #
      # @param [String, Pathname] root The application root path
      # @param [Hash{type=>Array<Symbol>}] options
      #
      # @option options [String] :repository The repository containing services metadata
      #
      # @return [void]
      def define(repository: nil) # rubocop:disable MethodLength, AbcSize
        require('oj')

        services = if ::File.exist?(path = ::File.expand_path(SERVICES_FILE, ::Dir.pwd))
          ::Oj.load_file(path, symbol_keys: true)
        else
          repository && _fetch(repository) ||
            raise(StandardError, "Services metadata not found at #{path}")
        end

        ::NAMESPACE.safe_const_set(:SERVICES, services.delete(:services).freeze)
        ::NAMESPACE.send(:private_constant, :SERVICES)

        services.each do |type, gems|
          ::NAMESPACE.safe_const_set(type.upcase, gems.map(&:to_sym))
          ::NAMESPACE.send(:private_constant, type.upcase)
        end

        true
      end

      # @raise [NameError] if constant undefined
      #
      # @return [Hash]
      def services; ::NAMESPACE.const_get(:SERVICES); end

      # @return [Bundler::Runtime]
      def bundler_environment; ::Bundler.environment; end

      # @return [Array<Bundler::Dependency>]
      def bundler_dependencies; bundler_environment.dependencies; end

      # Returns the `Bundler::Dependency` for each Piktur gem dependency
      #
      # @return [Array<Bundler::Dependency>]
      def dependencies
        bundler_dependencies.select { |e| e.name.start_with?('piktur') }
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
        gemspec = _find_gemspec(name)[0] unless gemspec.exist?

        return if gemspec.nil?

        ::Bundler.load_gemspec(gemspec)
      end

      private

        # @param [String] name The service name
        #
        # @return [Array<String>]
        def _find_gemspec(name)
          ::Dir.glob(
            "{gems/#{name}*/#{name}*,specifications/#{name}*}.gemspec",
            base: ::ENV['GEM_HOME']
          )
        end

        # @param [Module] namespace The root namespace
        # @param [Array<String>] args A list of gem names
        #
        # @return [Array<Hash>]
        def _services(args)
          args.zip(services.values_at(*args))
        end

        # @param [Array<Symbol>] args A list of gem names
        #
        # @return [Array<Hash>]
        def _get
          _services(::NAMESPACE.const_get(__callee__.upcase))
        end
        %i(applications engines libraries).each { |aliaz| alias_method(aliaz, :_get) }

        # Attempt to fetch services metadata from remote git repository.
        #
        # @param [String] repository
        #
        # @return [Hash] if request successful
        def _fetch(repository)
          branch = `#{File.expand_path('../../bin/git-branch', __dir__)} #{repository}`.chomp
          services = BITBUCKET_API +
            "repositories/piktur/#{repository}/src/#{branch}/#{SERVICES_FILE}"
          response = `curl -u $BITBUCKET_USER:$BITBUCKET_DEVELOPER_PASSWORD #{services}`

          ::Oj.load(response, symbol_keys: true) unless response.empty?
        end

    end

  end

end
