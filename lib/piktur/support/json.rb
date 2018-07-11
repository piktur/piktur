# frozen_string_literal: true

require 'active_support/json'

module Piktur

  module Support

    # @example Usage
    #   Support.install(:json)
    #
    # @example
    #   json = ActiveSupport::JSON.encode(object)
    #   hash = ActiveSupport::JSON.decode(json)
    #   hash = ActiveSupport::JSON.decode(json, symbol_keys: true)
    #
    # @example ActiveRecord
    #   object = Catalogue::Base.first
    #   ActiveSupport::JSON.encode object,
    #                              root:    true,
    #                              except:  :id,
    #                              include: { items: { only: [:id] } }
    #   # => "{\"portfolio\":{\"id\":2,\"active\":true, ... \"items\":[{\"id\":1}, ...]}}"
    #
    # @see https://github.com/rails/rails/blob/4-2-stable/activerecord/lib/active_record/connection_adapters/postgresql/oid/json.rb
    #   ActiveRecord handling of JSON data type
    #
    module JSON

      require 'oj'

      extend ::ActiveSupport::Autoload

      autoload :Encoder

      #   indent:                0,
      #   second_precision:      9,
      #   circular:              false,
      #   class_cache:           true,
      #   auto_define:           false,
      #   symbol_keys:           false,
      #   bigdecimal_as_decimal: true,
      #   nilnil:                false,
      #   allow_gc:              true,
      #   quirks_mode:           true,
      #   allow_invalid_unicode: false,
      #   float_precision:       15,
      #   escape_mode:           :json,
      #   time_format:           :unix_zone,
      #   bigdecimal_load:       :auto,
      #   create_id:             "json_class",
      #   space:                 nil,
      #   space_before:          nil,
      #   object_nl:             nil,
      #   array_nl:              nil,
      #   nan:                   :auto,
      #   omit_nil:              false,
      #   hash_class:            nil
      # @see https://github.com/ohler55/oj#options
      ::Oj.default_options = {
        use_as_json: true,
        mode:        :rails
      }

    end

  end

end

module ActiveSupport

  module JSON # rubocop:disable Documentation

    # Utilise Oj's built in Rails optimisations
    # Encoding.json_encoder = ::Piktur::Support::JSON::Encoder

    class << self

      def instance
        @instance ||= Encoding.json_encoder.new
      end

      # @overload decode(json, symbol_keys: true)
      #   Return symbol keyed Hash. Oj 2x faster than `Hash#deep_symbolize_keys!`
      #   @see http://bitbucket.org/piktur/piktur_core/benchmark//json.rb
      #   @return [Hash{Symbol=>Object}]

      # Decodes a JSON string into a Hash with Oj
      # @example
      #   ActiveSupport::JSON.decode("{\"key\":\"value\"}")
      #   # => {"key" => "value"}
      # @param [String] json
      # @param [Hash] options
      # @return [Object]
      def decode(*args)
        data = ::Oj.load(*args)
        ::ActiveSupport.parse_json_times ? convert_dates_from(data) : data
      end

      # Produce JSON string from object without stringent care for accurate type coercion
      # @param [Object] object
      # @return [String] JSON
      def encode(object, options = nil)
        instance.encode(object, *options) # *args
      end

      # Returns the class of the error that will be raised when there is an
      # error in decoding JSON. Using this method means you won't directly
      # depend on the ActiveSupport's JSON implementation, in case it changes
      # in the future.
      #
      # @example
      #   some_string = "hellish"
      #
      #   begin
      #     obj = ActiveSupport::JSON.decode(some_string)
      #   rescue ActiveSupport::JSON.parse_error
      #     Rails.logger.warn("Attempted to decode invalid JSON: #{some_string}")
      #   end
      # @return [void]
      def parse_error
        ::Oj::ParseError
      end

    end

  end

end

::Oj.optimize_rails
