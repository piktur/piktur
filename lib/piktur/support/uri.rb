# frozen_string_literal: true

module Piktur

  module Support

    # SerializableURI
    module SerializableURI

      # Implement `#as_json` on instance of `Object.URI`.
      # When called returns a String rather than `instance_values` Hash.
      # @return [URI]
      def URI(str) # rubocop:disable Style/MethodName
        Object.send(:URI, str).instance_eval do
          def as_json; to_s; end; self # rubocop:disable Style/Semicolon, Style/SingleLineMethods
        end
      end

    end

    # {URI} mimics `URI` providing limited interface with improved performance.
    #
    # @see file:spec/benchmark/requests.rb URI vs Struct
    # @see file:spec/benchmark/requests.rb BaseController#origin
    #
    # @example Split uri like string into components
    #   @origin ||= URI.new(
    #     request.env['Origin'] ||
    #     request.env['HTTP_ORIGIN'] ||
    #     Rails.env.development? && 'http://localhost'
    #   )
    #
    class URI

      # @return [Regexp]
      REGEX = /\A(http[s]?):[\/]{2}([a-z,A-Z,0-9]*)\/?([^:]*):?([0-9]*)\Z/

      # @!attribute uri
      #   @return [String]
      # @!attribute scheme
      #   @return [String]
      # @!attribute host
      #   @return [String]
      # @!attribute path
      #   @return [String]
      # @!attribute port
      #   @return [Fixnum]
      attr_accessor :uri, :scheme, :host, :path, :port

      # @param [String] uri
      def initialize(uri)
        @uri = uri.match(REGEX)[0]
        @scheme, @host, @path = $1, $2, $3 # rubocop:disable Style/ParallelAssignment
        @port = $4.to_i if $4.present?
      end

    end

  end

end
