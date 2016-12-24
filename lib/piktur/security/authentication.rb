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
    # Passwords are handled with `ActiveModel::SecurePassword` -- enabled with
    # `has_secure_password`.
    #
    # `Knock` -- a lightweight wrapper for `jwt` -- handles encoding/decoding JWT
    # (JSON Web Tokens) sent with a request via `Authorization` header or query paramater `token`.
    #
    # ## Protection spaces [realm]
    #
    # To obtain a `JWT` the request must include credentials valid within the either of the
    # following **protection spaces**.
    #
    # | Route             | Authenticable entity  | Realm        | Required attributes            |
    # | ----------------- | --------------------- | -------------| ------------------------------ |
    # | `api/v1/admin/*`  | {Subscriber}          | `Subscriber` | {User#email} + {User#password} |
    # | `api/v1/admin/*`  | {Admin}               | `Admin`      | {User#email} + {User#password} |
    # | `api/v1/client/*` | {Subscriber}          | `Visitor`    | {User#uuid}                    |
    #
    # Per [RFC2617](https://tools.ietf.org/html/rfc2617#section-3.2.1) if authentication
    # **challenged** the server **MUST** respond with a `WWW-Authenticate` header. The header
    # **MUST** include `Piktur::Api::V1::ApplicationController#realm`.
    #
    # Once a token has been obtained, the **client** must send it via the `Authorization` header
    # with all subsequent requests.
    #
    # The token payload **SHOULD** contain attributes {User#uuid} and {User#role}. Although
    # potentially slower to compare than id, its *ambiguity* prevents inference. These attributes
    # are used to identify the {User} and determine authorization.
    #
    # @see ApplicationPolicy
    # @see Piktur::Security::Authorization::Verifiers
    # @see https://bitbucket.org/piktur/rack_auth_jwt Rack::Auth::JWT
    #
    # ```ruby
    #   RSpec.describe Piktur::Api::V1::ApplicationController, type: :request do
    #     context 'when incoming request received' do
    #       context 'and path =~ /api\/v1\/client\/.*/' do
    #         before(:all) do
    #           @entity = Subscriber.first
    #           @token  = Knock::AuthToken.new(payload: Subscriber.to_token_payload)
    #
    #           get portfolios_path,
    #               { token: @token },                        # params
    #               { 'Authorization' => "Bearer #{@token}" } # headers
    #         end
    #
    #         describe 'headers' do
    #           let(:parts) { request.headers['Authorization'].split }
    #
    #           it "MUST include 'Authorization'" do
    #             expect(request.headers).to have_key('Authorization')
    #           end
    #
    #           it "MUST declare 'Bearer' scheme" do
    #             expect(parts[0]).to eq 'Bearer'
    #           end
    #
    #           it "MUST include JWT" do
    #             expect(Knock::AuthToken.new(token: parts[1])).not_to raise_exception
    #           end
    #         end
    #
    #         context 'with params[:token]' do
    #           describe 'params' do
    #             it "MUST include JWT" do
    #               expect(Knock::AuthToken.new(token: params[:token])).not_to raise_exception
    #             end
    #           end
    #         end
    #
    #         context 'then set @_current_user' do
    #           context 'then check @_current_user authorized' do
    #             context 'when @_current_user authorized' do
    #               describe 'response' do
    #                 describe 'status' do
    #                   it { expect(response.status).to eq 200 }
    #                 end
    #               end
    #             end
    #
    #             context 'when @_current_user NOT authorized' do
    #               describe 'response' do
    #                 describe 'status' do
    #                   it { expect(response.status).to eq 403 }
    #                 end
    #               end
    #             end
    #           end
    #         end
    #
    #         context "with neither 'Authorization' header or params[:token]" do
    #           describe 'response' do
    #             describe 'status' do
    #               it { expect(response.status).to eq 401 }
    #             end
    #
    #             describe 'headers' do
    #               it { expect(response.headers).to have_key('WWW-Authenticate') }
    #             end
    #           end
    #
    #           context "THEN the client should try to retrieve a token from
    #                    'POST api/v1/admin/token'" do
    #             context "path =~ /api\/v1\/admin\/.*/" do
    #               context "with params[:auth][:email] AND params[:auth][:password]" do
    #                 describe 'params[:auth]' do
    #                   it "should find User with matching #email" do
    #                     expect(User.find_by(email: params[:auth][:email])).to be_present
    #                   end
    #                 end
    #               end
    #             end
    #           end
    #
    #           context "THEN the client should try to retrieve a token from
    #                    'POST api/v1/client/token'" do
    #             context "with params[:auth]" do
    #               describe 'params[:auth]' do
    #                 it "should find User with matching #uuid" do
    #                   expect(User.find_by(uuid: params[:auth])).to be_present
    #                 end
    #               end
    #
    #               context 'when User found' do
    #                 describe 'response' do
    #                   describe 'status' do
    #                     it { expect(response.status).to eq 201 }
    #                   end
    #
    #                   describe 'body' do
    #                     it { expect(ActiveSupport::JSON.decode(response.body)).to \
    #                       have_key('jwt') }
    #                   end
    #                 end
    #               end
    #
    #               context 'when User NOT found' do
    #                 describe 'response' do
    #                   describe 'status' do
    #                     it { expect(response.status).to eq 401 }
    #                   end
    #
    #                   describe 'headers' do
    #                     it { expect(response.headers).to have_key('WWW-Authenticate') }
    #                   end
    #                 end
    #               end
    #             end
    #           end
    #
    #           context "THEN the client should store the token" do
    #
    #           end
    #
    #           context "AND send it with subsequent requests" do
    #
    #           end
    #         end
    #       end
    #     end
    #   end
    #
    # ```
    #
    module Authentication

      extend ActiveSupport::Autoload

      eager_autoload do
        autoload :UserProxy
      end

      autoload :User
      autoload :Admin
      autoload :Subscriber

    end

  end

end
