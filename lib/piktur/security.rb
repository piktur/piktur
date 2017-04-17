# frozen_string_literal: true

require 'active_support/core_ext/module/remove_method'
require 'bcrypt'
require 'knock'
require 'pundit'
require 'rack/auth/jwt'

# @option [ActiveSupport::Duration] token_expires_in Token will not expire if nil
# @option [Proc] token_audience
#   Configure the audience claim to identify the recipients that the token is intended for.
# @option [String] token_signature_algorithm
#   Configure the algorithm used to encode the token
# @option [Proc] token_secret_signature_key
#   Configure the key used to sign tokens.
#   Use ENV['AUTH0_CLIENT_SECRET'] or ENV['SECRET_KEY_BASE']
# @option [String, NilClass] token_public_key
#   Configure the public key used to decode tokens, if required.
# @option [Class] not_found_exception_class_name
#   Exception to raise when entity instance not found
Knock.setup do |c|
  c.token_expires_in               = 1.day
  # @example Auth0
  #   -> { ENV['AUTH0_CLIENT_ID'] }
  c.token_audience                 = -> { Piktur::Services.production_servers }
  c.token_signature_algorithm      = 'HS256'
  c.token_public_key               = nil
  c.not_found_exception_class_name = 'Piktur::NotAuthorizedError'
  c.token_secret_signature_key     = lambda do
    JWT.base64url_decode ENV['AUTH0_CLIENT_SECRET']
  end
end

# Use `Object.const_get` rather than `String#constantize`
Knock.redefine_method(:not_found_exception_class) do
  Object.const_get(not_found_exception_class_name)
end

module Piktur

  # Raise when auth params invalid. Prefer conditional to exception callbacks.
  # @example
  #   unauthorized unless params[:auth][:email] && User::Base.find_by(email: params[:auth][:email])
  NotAuthorizedError =
    Class.new(defined?(ActionController) ? ActionController::ActionControllerError : StandardError)

  # {include:Security::Authentication}
  # {include:Security::Authorization}
  module Security

    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Authentication
      autoload :Authorization
      autoload :BasePolicy
    end

  end

end
