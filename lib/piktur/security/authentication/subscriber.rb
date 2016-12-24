# frozen_string_literal: true
# rubocop:disable Rails/DynamicFindBy

module Piktur

  module Security

    module Authentication

      # Authentication logic for {Subscriber}
      module Subscriber

        # @param [Class, Module] base
        # @return [void]
        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
        end

        # ClassMethods
        module ClassMethods

          # Distinguish {Subscriber}/{Admin} from `Visitor` and find by relevant parameters.
          # {include:User::ClassMethods#from_token_request}
          # @param [ActionDispatch::Request] request
          # @raise Knock.not_found_exception_class_name
          # @return [Subscriber, nil]
          def from_token_request(request)
            controller = request.params[:controller]

            if controller.include?('admin')
              find_by_email(request.params[:auth] && request.params[:auth][:email])
            elsif controller.include?('client')
              find_by_uuid(request.params[:auth])
            end
          end

          # Find {User} by {User#uuid} stored within decoded `JWT`
          # @return [User, nil]
          def from_token_payload(payload)
            includes(:account).find_by_uuid(payload['sub']['uuid'])
          end

        end

        # InstanceMethods
        module InstanceMethods

          # Override User::InstanceMethods

        end

      end

    end

  end

end
