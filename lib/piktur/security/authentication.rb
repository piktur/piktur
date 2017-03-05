# frozen_string_literal: true
# rubocop:disable Rails/DynamicFindBy

module Piktur

  module Security

    # ## Authentication (based on `knock`)
    #
    # Implements:
    # - [OAuth 2.0 Bearer Authentication RFC 6750](https://tools.ietf.org/html/rfc6750)
    # - [JSON Web Token (JWT) RFC 7519](https://tools.ietf.org/html/rfc7519)
    #
    # `Knock` -- a lightweight wrapper for `jwt` -- handles encoding/decoding JWT
    # (JSON Web Tokens) sent with a request via `Authorization` header or query paramater `token`.
    #
    # Once a token has been obtained, the **client** must send it via the `Authorization` header
    # with all subsequent requests.
    #
    # @see ApplicationPolicy
    # @see Piktur::Security::Authorization::Verifiers
    # @see https://bitbucket.org/piktur/rack_auth_jwt Rack::Auth::JWT
    module Authentication

      extend ActiveSupport::Autoload

      eager_autoload do
        autoload :UserProxy
      end

    end

  end

end
