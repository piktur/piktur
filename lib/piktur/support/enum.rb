# frozen_string_literal: true

# rubocop:disable FormatString, DynamicFindBy

module Piktur

  module Support

    # Enum maps static values and translation to a developer friendly identifier.
    #
    # @see https://bitbucket.org/piktur/piktur/issues/1/optimise-piktur-support-enum
    #
    # @example
    #   class WithEnum
    #     # The enumerable attribute
    #     attr_accessor :enumerable
    #
    #     # Provide the namespace and a name for the enumerable collection to the constructor
    #     Types.Enum self, :enumerable do
    #       i18n_scope :with_enum
    #       predicates :enumerable # Includes predicate methods for instances of the class
    #
    #       default :a           # Set the default value
    #       value   :b           # Define additional values
    #       value   :c, meta: {} #
    #
    #       finalize do |enum|
    #         def enum.extended?; true; end
    #       end
    #     end
    #   end
    #
    #   enum = Types['enum.with_enum.enumerable'] # => <Enum[enumerable] a=0 b=1 c=2>
    #
    #   enum[:a]        # => <Enum::Value a=0 default=true>
    #   enum.a          # => <Enum::Value a=0 default=true>
    #   enum.default    # => <Enum::Value a=0 default=true>
    #   enum[1]         # => <Enum::Value b=1>
    #
    #   enum[0].to_i    # => 0
    #   enum[0].to_s    # => 'a'
    #   enum[0].as_json # => 0
    #   enum[:a].human  # => 'Type A'
    #
    #   enum.extended?  # => true
    #
    #   enum[0] == 0    # => true
    #   enum[0] == :a   # => true
    #
    #   obj = WithEnum.new(enumerable: :a)
    #   obj.a? # => true
    #   obj.b? # => false
    class Enum

      extend ::ActiveSupport::Autoload

      require 'piktur/support/enum/constructor'

      autoload :Predicates
      autoload :Type
      autoload :Validator
      autoload :Value

      # @return [Symbol]
      I18N_NAMESPACE = :enum

      # @return [String]
      ENUM_FROZEN_MSG = %(can't modify frozen %s)
      private_constant :ENUM_FROZEN_MSG

      # @return [String]
      NOT_FOUND_MSG = %(Value "%{value}" not in %{enum}.)
      private_constant :NOT_FOUND_MSG

      # include Validator
      include Type

      # @!attribute [r] name
      #   @return [Symbol]
      attr_reader :name

      # @!attribute [r] mapping
      #   @return [Struct]
      attr_reader :mapping

      # @!attribute [r] keys
      #   @return [Array<Symbol>]
      attr_reader :keys

      # @!attribute [r] values
      #   @return [Array<Value>]
      attr_reader :values

      # @!attribute [rw] i18n_scope
      #   @return [Array<Symbol>]
      attr_reader :i18n_scope

      # @param [String, Symbol]
      #
      # @return [Array<Symbol>]
      def i18n_scope=(namespace)
        @i18n_scope = [I18N_NAMESPACE, *namespace, name].freeze
      end

      # @param [Symbol, String, Integer] input
      #
      # @return [Value]
      def call(input)
        find(input) || default
      end

      # @!group Queries

      # @!method find_by_key
      # @!method find_by_value
      #
      # @param [String, Symbol, Integer] value
      #
      # @return [Value]
      def find(value); find_by_value(value) || find_by_key(value); end

      # @raise [IndexError] if value out of range
      # @raise [NameError] if key missing
      #
      # @return [Value]
      def find!(value); mapping[value]; end
      alias [] find!

      def find_by_key(key); values.each { |obj| break(obj) if obj == key }; end

      def find_by_value(value); values.each { |obj| break(obj) if obj == value }; end

      # @!method []
      # @!method find!
      # @!method find_by_key!
      # @!method find_by_value!
      # @param [Object] value
      # @raise [ArgumentError]
      # @return [Enum::Value]

      def find_by_key!(key); find_by_key(key) || not_found!(value); end

      def find_by_value!(value); find_by_value(value) || not_found!(value); end

      # @return [Boolean]
      def include?(value); find(value).present?; end

      # @return [Enum::Value]
      def default; @default ||= mapping.each { |e| break(e) if e.default? }; end

      # @return [Integer]
      # @return [nil] if default value not set
      def default_value; default&.value; end

      # @!endgroup

      # @!group Enumeration

      # @return [Integer] the number of enumerated values
      def size; mapping.size; end
      alias length size

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def each(&block); mapping.each(&block); end

      # @yieldparam [Symbol] key
      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def each_pair(&block); mapping.each_pair(&block); end

      # @yieldparam [Value] value
      #
      # @return [Enumerator]
      def select(&block); mapping.select(&block); end

      # @param [Array<Integer, Symbol>] args
      #
      # @return [Array<Value>]
      def values_at(*args); mapping.values_at(*args); end

      # @return [Enumerator]
      def to_enum; mapping.enum_for; end

      # @!method to_a
      #   @return [Array<Enum::Value>]
      alias to_a values

      # @!endgroup

      # @return [String]
      def human(*); Support::Inflector.humanize(name); end

      # @return [String]
      def to_s; name.to_s; end

      # @return [Hash]
      def to_hash; h = {}; each { |v| h[v.key] = v.value }; h; end
      alias to_h to_hash

      # @!group Builders

      # @param [String, Symbol] attribute
      #
      # @return [Module]
      def predicates(attribute); Predicates[attribute, self]; end

      # @!endgroup

      # @return [String]
      def inspect
        "<Enum[#{key}] #{each_pair.with_object(String.new) { |(k,v), s| s << " #{k}=#{v.to_i}" }}>"
      end

      private

        # @return [true] if {#key} include the method name
        def respond_to_missing?(method_name, include_private = false)
          keys.include?(method_name) || super
        end

        # Forwards the method call to {#mapping}
        #
        # @raise [NoMethodError]
        # @return [void]
        def method_missing(method_name, *args)
          respond_to_missing?(method_name) && mapping.send(method_name) || super
        end

        # * Store {Value} under `key`
        # * Define scoped `I18n` helper
        # * Define method for `key`
        #
        # @return [void]
        def declare!(key, value: nil, **options)
          # validate!((key = key.to_sym), value)
          Value.new(key: key, value: value, **options)
        end

        # Build {Value} for each in `enumerable` collection.
        #
        # @param [Hash] enumerable
        #
        # @return [void]
        def map(enumerable)
          @mapping = ::Struct.new(*enumerable.keys).allocate

          enumerable.each.with_index do |(key, options), i|
            options[:value] = i
            value = declare!(key, i18n_scope: @i18n_scope, **options)
            @mapping[key] = value
          end

          @keys   = @mapping.members.freeze
          @values = @mapping.values.freeze
          @mapping.freeze
        end

        # @param [Numeric] value
        #
        # @raise [ArgumentError] if value missing
        def not_found!(value)
          raise ::ArgumentError, NOT_FOUND_MSG % { value: value, enum: name }
        end

    end

  end

end
