# frozen_string_literal: true

require 'dry-configurable'

module Piktur

  # Thread safe configuration store
  class Config

    extend ::Dry::Configurable

    # @!method services(%w(piktur_library piktur_engine piktur_application))
    #   @see Piktur::Services
    #   @return [Services::Index]
    setting(:services, reader: true) { |dependencies| Services::Index.new(*dependencies) }

  end

end
