# frozen_string_literal: true

module Piktur

  module Security

    module Authorization

      # Mixin adds shared `ActiveRecord` methods for **authorizable entity** models.
      module Authorizable

        extend ActiveSupport::Concern

        included do
          class << self

            attr_accessor :default_role

            # @note base classes **MUST** reimplement this method
            # @return [Integer]
            def self.default_role
              raise NotImplementedError
            end

          end

          # Set default value for key 'role' on underlying `attributes` hash.
          # **Apply default to new records only!**
          # The record **MUST** be assumed compromised if unexpected role returned.
          # @see Piktur::Security::Authorization::ROLES
          # @return [Integer]
          def role
            new_record? ? (self['role'] ||= self.class.default_role) : self['role']
          end
        end

      end

    end

  end

end
