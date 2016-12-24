# frozen_string_literal: true

module Piktur

  module Support

    # {Uri} mimics `URI` providing limited interface with improved performance.
    #
    # @see file:spec/benchmark/requests.rb URI vs Struct
    # @see file:spec/benchmark/requests.rb BaseController#origin
    #
    # @example Split uri like string into components
    #   @origin ||= Uri.new(
    #     request.env['Origin'] ||
    #     request.env['HTTP_ORIGIN'] ||
    #     Rails.env.development? && 'http://localhost'
    #   )
    #
    class Uri

      # @return [Regexp]
      REGEX = /^(http[s]?):[\/]{2}([a-z,A-Z,0-9]*)\/?([^:]*):?([0-9]*)$/

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
        # rubocop:disable Style/PerlBackrefs
        @uri = uri.match(REGEX)[0]
        @scheme, @host, @path = $1, $2, $3
        @port = $4.to_i if $4.present?
      end

    end

  end

end
