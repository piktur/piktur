# frozen_string_literal: true

module Piktur

  module Security

    module Authorization

      # To ensure performant equality check {User} stores {User#role} as an `Integer`. {Roles} adds
      # helper per {Authorization::ROLES} entry to improve readability.
      module Roles

        # @!method find_role
        #   @see Piktur::Security::Authorization::ROLES.find_role
        #   @return [String, Fixnum]
        # @!method subscribers
        #   @see Piktur::Security::Authorization::ROLES.subscribers
        #   @return [Range]
        delegate :find_role, :subscribers, to: '::Piktur::Security::Authorization::ROLES'

        # @!method piktur_basic
        # @!method piktur_standard
        # @!method piktur_complete
        # @!method subscriber_basic
        # @!method subscriber_standard
        # @!method subscriber_complete
        # @!method admin
        # @!method customer
        # @return [Integer]
        ::Piktur::Security::Authorization::ROLES.each.with_index do |role, i|
          define_method(role) { i }
          define_method(role.sub('piktur', 'subscriber')) { i } if role =~ /^piktur_/
        end

      end

    end

  end

end
