# frozen_string_literal: true

module Piktur

  module Security

    module Authentication

      # The proxy object enables {User} authentication for applications without a database
      # connection ie. `Piktur::Docs`, or any endpoint protected by `Rack::Auth::JWT`
      # middleware. The {User} must obtain a token in the usual way.
      #
      # ```sh
      #   curl -P https://api.piktur.io/v1/token \
      #     -d 'auth[email]=admin@example.com' \
      #     -d 'auth[password]=password'
      # ```
      #
      # ```json
      #   {"jwt":"xxx0xxxxxxxxx0xxxxxxxxxxxxxxxxx0xxx0.xxxxxxxxxxx0xxxxxxxxxxxxxxx0xxx0xxx0xxxxxxx0xxxxxxx0xxx0xxxxxxxxx0xxxxx0xxxxxxxxx0xxxxxxxx.xxx0x000xxxxxxx-xxxxxx_x0x0xxx0xxx-xx0xxxxx"}
      # ```
      #
      # ```bash
      #   curl -G docs.piktur.io
      #     -H Authorization: Bearer xxx0xxxxxxxxx0xxxxxxxxxxxxxxxxx0xxx0.xxxxxxxxxxx0xxxxxxxxxxxxxxx0xxx0xxx0xxxxxxx0xxxxxxx0xxx0xxxxxxxxx0xxxxx0xxxxxxxxx0xxxxxxxx.xxx0x000xxxxxxx-xxxxxx_x0x0xxx0xxx-xx0xxxxx
      # ```
      #
      module UserProxy

        # @!method from_token_request(request)
        #   @!scope class
        #   @see Authentication::User::ClassMethods#from_token_request
        #   @param [ActionDispatch::Request] request
        #   @raise Knock.not_found_exception_class_name
        #   @return [User, nil]
        # @!method from_token_payload(base)
        #   @!scope class
        #   Instantiate if `payload['sub']['role']` contains expected role
        #   @param [Hash] payload
        #   @return [User, nil]
        # @!method uuid
        #   Returns a reference to parent instance
        #   @return [String]
        # @!method role
        #   @note It may be wise to limit authorization for the proxy object
        #   @return [Integer]
        # @!method to_token_payload
        #   Prepare authenticable entity attribute(s) for encoding.
        #   Token payload **MUST** contain key `role`.
        #   @return [Hash{Symbol=>String}]

        # @param [Class, Module] base
        # @return [void]
        def self.extended(base)
          role = Authorization.send(base.name.downcase)
          base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            delegate :from_token_request, to: #{base}

            def self.from_token_payload(payload)
              new(payload['sub']['uuid']) if payload['sub']['role'] == #{role}
            end

            attr_accessor :uuid, :role

            # @param [String] uuid The parent instance's uuid
            def initialize(uuid)
              self.uuid = uuid
              self.role = #{role}
            end

            def to_token_payload
              { sub: { role: role, uuid: uuid } }
            end
          RUBY
        end

      end

    end

  end

end
