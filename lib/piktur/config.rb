# frozen_string_literal: true

require 'dry-configurable'

module Piktur

  # Thread safe configuration store
  class Config

    extend ::ActiveSupport::Autoload
    extend ::Dry::Configurable

    # @!method services
    #   @example Piktur.config.services = %w(piktur_library piktur_engine piktur_application)
    #   @see Piktur::Services
    #   @return [Services::Index]
    setting(:services, reader: true) { |services| Services::Index.new(*services) }

  end

end
