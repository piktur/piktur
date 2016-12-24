# frozen_string_literal: true

module Piktur

  module Security

    # Controller methods used to authenticate {User} from **JSON Web Token (JWT)** payload.
    # Implementation based on `Knock::Authenticable`.
    # @see https://bitbucket.org/snippets/piktur/aa8MA `Knock::Authenticable` examples
    module Requests

      private

        include Security::Authorization::Verifiers

        # Render {ErrorResponses#unauthorized} or set `@_current_entity`
        # @return [String, User]
        def authenticate_entity
          unauthorized_entity unless current_entity
        end

        # Render {ErrorResponses#unauthorized} when entity not authenticated
        def unauthorized_entity
          unauthorized
        end

        # @return [String]
        def token
          params[:token] || token_from_request_headers
        end

        # @return [String]
        def token_from_request_headers
          request.headers['Authorization'].split[-1] unless request.headers['Authorization'].nil?
        end

        # @return [Class]
        def entity_class(role)
          if role.in?(subscribers)
            ::Subscriber
          elsif admin
            ::Admin
          elsif customer
            ::Customer
          end
        end

        # @return [User, nil]
        def current_entity
          return @_current_entity if @_current_entity
          return if token.nil?

          decoded = ::Knock::AuthToken.new(token: token)
          payload = decoded.payload

          @_current_entity ||= decoded.entity_for(entity_class(payload['sub']['role']))
          @_current_entity.readonly! if api_domain == 'Client'
          @_current_entity
        end
        alias entity current_entity

    end

  end

end
