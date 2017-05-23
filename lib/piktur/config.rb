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

    # Prevent instantiation of {Piktur::Services} objects.
    # config.instance_exec do
    #   def finalize!
    #     ::Piktur::Services.constants.each do |const|
    #       const = ::Piktur::Services.const_get(const)
    #       const.private_class_method :new if const.is_a?(Class)
    #     end
    #     super
    #   end
    # end

  end

end
