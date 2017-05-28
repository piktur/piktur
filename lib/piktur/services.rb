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
  #     |-- /piktur_api      # Piktur::Api
  #     |-- /piktur_blog     #
  #     |-- /piktur_client   # Piktur::Client
  #     |-- /piktur_core     # Piktur::Core
  #     |-- /piktur_docs     # Piktur::Docs
  #     |-- /piktur_security # Piktur::Security
  #     |-- /piktur_store    # Piktur::Store
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
    SERVICES = Oj.load(File.read(Piktur.root.join('config', 'services.json')))['services']
      .deep_symbolize_keys!
      .freeze

    class << self

      private

        # @param [Array<String>] services
        # @return [Array<Hash>]
        def services_data(services)
          SERVICES.select { |k,| k.in?(services) }.to_a
        end

        # @return [Array<Hash>]
        def libraries
          services_data %i(
            piktur
            piktur_security
          )
        end

        # @return [Array<Hash>]
        def engines
          services_data %i(
            piktur_core
            piktur_store
          )
        end

        # @return [Array<Hash>]
        def applications
          services_data %i(
            piktur_api
            piktur_admin
            piktur_blog
            piktur_client
            piktur_docs
          )
        end

    end

  end

end
