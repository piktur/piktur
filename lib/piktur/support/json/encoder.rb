# frozen_string_literal: true

module Piktur

  module Support

    module JSON

      # `ActiveSupport` implements `#to_json` for all core Ruby objects encoding the object as an
      # equivalent JSON primitive. In addition to a default encoder, ActiveSupport also exposes an
      # api allowing the encoder to be replaced [here](https://gist.github.com/chancancode/ff3093b101d934065d1f#activesupport-json-encoder-interface)
      #
      # `#to_json` calls `ActiveSupport::JSON.encode` via
      # `Object#to_json_with_active_support_encoder`, where possible Objects should control
      # serialization via `#to_hash` or `#as_json`. The `#as_json` hook allows an object to
      # implement custom coercion from Ruby types to JSON primitives without encoding to JSON
      # String. It is considered a "hint" for JSON encoders. Notably, it is NOT required to return
      # a JSON primitive. If the implementation chooses to return a non-primitive, it is then up to
      # the encoder to interpret the result.
      #
      # @note `:compat` mode attempts to be compatible with other systems. It will
      #   serialize any Object, but will check to see if the Object implements
      #   `#to_hash`, `#to_json` or `#as_json` method. If any of these methods is defined, it will
      #   be used to serialize the Object. If both `#as_json` and `#to_json` defined, `#as_json`
      #   has precedence. If none, then Oj will use its internal Object encoder.
      #
      # @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/json/encoding.rb#L168
      # @see https://gist.github.com/chancancode/ff3093b101d934065d1f
      # @see https://precompile.com/2015/07/25/rails-activesupport-json.html
      # @see file:http://bitbucket.org/piktur/piktur_core/benchmark//json.rb Benchmarks
      #
      class Encoder < ::ActiveSupport::JSON::Encoding::JSONGemEncoder

        # `#jsonify` recursively transforms a Ruby object to Ruby equivalent JSON primitive. If the
        # object implements `#as_json` `#jsonify` will utilise it. Virtually all available JSON
        # libraries will be able to encode the output of this algorithm and produce consistent
        # results. Although potentially error prone, we forego `#jsonify` using
        # `Oj.dump(object, mode: :compat)` in `:compat` mode as it is substantially faster.
        # @return [Object]
        def jsonify(value, options = nil)
          case value
          when String then EscapedString.new(value)
          when Numeric, NilClass, TrueClass, FalseClass then value.as_json(options)
          when Hash then Hash[value.map { |k, v| [jsonify(k, options), jsonify(v, options)] }]
          when Array then value.map { |v| jsonify(v, options) }
          else jsonify value.as_json(options)
          end
        end

        # @param [Object] object
        # @param [Hash] options
        # @return [String] JSON
        def encode(object, options = nil)
          # stringify(jsonify(object, options))
          stringify(object, *options)
        end

        # Produce JSON string from object
        # @note Utilises Oj `compat` mode coercion.
        # @param [Object] object
        # @param [Hash] options
        # @return [String] JSON
        def stringify(object, options = nil)
          ::Oj.dump(object, *options)
        end

      end

    end

  end

end
