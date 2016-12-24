# frozen_string_literal: true
# rubocop:disable Rails/DynamicFindBy

module Piktur

  module Security

    module Authentication

      # Authentication logic for {User}
      module User

        # @param [Class, Module] base
        # @return [void]
        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
          base.has_secure_password
        end

        # ClassMethods
        module ClassMethods

          # According to `Piktur::Api::V1::ApplicationControler#realm` finds {User} by relevant
          # attributes
          #
          # ```ruby
          #   Admin      => request.params[:auth][:email] # User#email
          #   Subscriber => request.params[:auth][:email] # User#email
          #   Visitor    => request.params[:auth]         # User#uuid
          # ```
          #
          # @see https://bitbucket.org/piktur/piktur_core/src/master/piktur_core/spec/benchmark/has.rb #dig vs #[]
          #
          # @param [ActionDispatch::Request] request
          # @raise Knock.not_found_exception_class_name
          # @return [User, nil]
          def from_token_request(request)
            find_by_email(request.params[:auth] && request.params[:auth][:email])
          end

          # Find {User} by {User#uuid} stored within decoded `JWT`
          # @return [User, nil]
          def from_token_payload(payload)
            find_by_uuid(payload['sub']['uuid'])
          end

        end

        # InstanceMethods
        module InstanceMethods

          # Prepare authenticable entity attribute(s) for encoding.
          # Token payload **MUST** contain {User#uuid} and {User#role}
          # @return [Hash{Symbol=>String}]
          def to_token_payload
            { sub: { role: role, uuid: uuid } }
          end

        end

      end

    end

  end

end
