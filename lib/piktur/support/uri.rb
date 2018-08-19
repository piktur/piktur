# frozen_string_literal: true

module Piktur

  module Support

    # SerializableURI
    module SerializableURI

      # Implement `#as_json` on instance of `Object.URI`.
      # When called returns a String rather than `instance_values` Hash.
      #
      # @return [URI]
      def URI(str) # rubocop:disable MethodName
        str = ::Object.send(:URI, str)
        def str.as_json(*); to_s; end
        str
      end

    end

    # {URI} mimics `URI` providing limited interface with improved performance.
    #
    # @see file:benchmark//requests.rb URI vs Struct
    # @see file:benchmark//requests.rb BaseController#origin
    #
    # @example Split uri like string into components
    #   @origin ||= URI.new(
    #     request.env['Origin'] ||
    #     request.env['HTTP_ORIGIN'] ||
    #    ::NAMESPACE.env.development? && 'http://localhost'
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
        (@uri = uri) =~ REGEX
        @scheme, @host, @path = $1, $2, $3 # rubocop:disable ParallelAssignment
        @port = $4.to_i if $4.present?
      end

    end

  end

end
