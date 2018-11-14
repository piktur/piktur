# frozen_string_literal: true

module Piktur::Services # rubocop:disable ClassAndModuleChildren

  module Delegates # rubocop:disable Documentation

    # @return [Services::Index]
    def services(options = EMPTY_HASH); @services ||= Index.new(options); end

    # Returns Service object for current application
    #
    # @return [Services::Service]
    def application; services.application; end

    # @return [Array<Services::Application>]
    def applications; services.applications; end

    # @return [Array<Services::Engine>]
    def engines; services.engines; end

    # @return [Array<Services::Library>]
    def libraries; services.libraries; end

    # @return [Array<Rails::Railtie>]
    def railties; services.railties; end

    # @return [Services::Index]
    def dependencies; services.dependencies; end

    # Remote server metadata for {.services}
    #
    # @return [Services::Server]
    def servers; services.servers; end

    # @note Defaults to localhost if running dummy app
    #
    # @return [URI::Generic]
    def server
      if application.nil? || application.engine?
        servers.default
      else
        application.server.uri
      end
    end

    # @return [Array<Module>]
    def eager_load_namespaces; services.eager_load_namespaces; end

    # Returns the canonical file index for all loaded {.services}
    #
    # @return [Array<Services::FileIndex::Pathname>]
    def file_index; services.file_index.all; end

  end

end
