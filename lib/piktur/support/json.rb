# frozen_string_literal: true

module Piktur

  module Support

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
        use_to_json: true,
        use_as_json: true,
        mode:        :compat
      }

      extend ActiveSupport::Autoload

      autoload :Encoder

      # Optimised JSON Extension
      Ext = proc do |klass|
        klass::Encoding.json_encoder = Encoder

        class << klass
          %i(decode fast_encode encode parse_error).each do |m|
            remove_possible_method(m)
          end

          def instance
            @instance ||= Encoder.new
          end

          # @overload decode(json, symbol_keys: true)
          #   Return symbol keyed Hash. Oj 2x faster than `Hash#deep_symbolize_keys!`
          #   @see http://bitbucket.org/piktur/piktur_core/spec/benchmark/json.rb
          #   @return [Hash{Symbol=>Object}]

          # Decodes a JSON string into a Hash with Oj
          # @example
          #   ActiveSupport::JSON.decode("{\"key\":\"value\"}")
          #   # => {"key" => "value"}
          # @param [String] json
          # @param [Hash] options
          # @return [Object]
          def decode(json, options = nil)
            data = ::Oj.load(json, options)
            ::ActiveSupport.parse_json_times ? convert_dates_from(data) : data
          end

          # Produce JSON string from object without stringent care for accurate type coercion
          # @param [Object] object
          # @param [Hash] options
          # @return [String] JSON
          def fast_encode(object, options = nil)
            instance.stringify(object, options)
          end

          # Produce JSON string from object
          # @param [Object] object
          # @param [Hash] options
          # @return [String] JSON
          # def encode(object, options = nil)
          #   @instance.encode(object, options)
          # end
          alias_method :encode, :fast_encode

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

      # @return [void]
      def self.install(*)
        ::ActiveSupport::JSON.class_eval(&Ext)
      end
      private_class_method :install

    end

  end

end
