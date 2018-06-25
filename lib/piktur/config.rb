# frozen_string_literal: true

require 'dry-configurable'

module Piktur

  # Thread safe configuration store
  class Config

    extend ::ActiveSupport::Autoload
    extend ::Dry::Configurable

    # @!attribute [rw] services
    #   @example
    #     Piktur::Config.configure do |config|
    #       config.services = %w(piktur_library piktur_engine piktur_application)
    #
    #       # With options
    #       config.services = %w(lib).push(component_types: [:models, :serializers])
    #     end
    #
    #   @see Piktur::Services
    #   @return [Services::Index]
    setting(:services, reader: true) do |services|
      options = services.pop if services && services[-1].is_a?(::Hash)
      Services::Index.new(services.map(&:to_s), options || EMPTY_HASH)
    end

  end

end
