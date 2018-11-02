# frozen_string_literal: true

module Piktur

  # :nodoc
  module Errors

    module_function

    # @param [String] str
    # @return [void]
    def debug(str); parent.logger.debug(str); end

    # @param [String] str
    # @return [void]
    def warn(str); parent.logger.warn(str); end

    # @param [String, Exception] error
    # @return [void]
    def error(err)
      case err
      when ::String    then parent.logger.error(err)
      when ::Exception then parent.logger.error(err.full_message)
      end
    end

    # @param [Symbol] sym
    # @return [void]
    def throw(sym); ::Kernel.throw(sym); end

    # @param [Exception] exception
    # @return [void]
    def raise(exception); ::Kernel.raise(exception); end

    # Enum mapping status codes to application errors
    class Enum < Support::Enum

      # :nodoc
      class Value < Support::Enum::Value

        # @return [Integer]
        def code; value; end

        # @return [Array<Exception>]
        def exceptions; meta[__method__]; end

      end

      # @param [String, Symbol, Integer, Value] input
      #
      # @return [Value, nil]
      def find(input)
        super || default
      end
      alias [] find

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def each(&block); values.each(&block); end

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def select(&block); values.select(&block); end

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def map(&block); values.map(&block); end

      # @return [Enum::Value]
      # @return [nil] if default value not set
      def default
        return @default if defined?(@default) # @default may be nil

        @default = values.find(&:default?)
      end

      private def build(enumerable)
        @mapping = {}

        enumerable.each.with_index do |(key, options), i|
          options[:value] = options.delete(:code)
          value = declare!(key, i18n_scope: @i18n_scope, enum: self, **options)
          @mapping[key] = value
        end

        @keys = @mapping.keys.freeze
        @values = @mapping.values.freeze
        @mapping.freeze
      end

    end

  end

  # @return [String]
  CLONE_WARNING = <<~MSG
    Use %{method} to make a copy of this class.
  MSG

  # @return [StandardError]
  MethodDefinedError = ::Class.new(::StandardError)

end
