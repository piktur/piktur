# frozen_string_literal: true

# rubocop:disable ParallelAssignment, SymbolProc, FormatString

module Piktur

  module Support

    # @example Performance of enumerated collection
    # ```
    #   require 'benchmark'
    #   require 'benchmark/ips'
    #
    #   n = 1_000_000
    #
    #   male = ::Genders[:male]
    #
    #   Benchmark.bmbm do |x|
    #     x.report('local var cache') { n.times { male } }
    #     x.report('singleton method') { n.times { ::Genders.male(false) } }
    #     x.report('find') { n.times { ::Genders[:male] } }
    #   end
    #
    #   Benchmark.ips do |x|
    #     x.report('local var cache') { male }
    #     x.report('singleton method') { ::Genders.male(false) }
    #     x.report('find') { ::Genders[:male] }
    #
    #     x.compare!
    #   end
    # ```
    #
    # @example
    #   class Example
    #     ::Enum[
    #       Module,
    #       :collection,
    #       predicates: 'collection',
    #       a: { value: 0, default: true }
    #       b: { value: 10 }
    #       c: { value: 100 }
    #     ]
    #   end
    #
    #   Example::Enum[0].value # => 0
    #
    # @param [Class, Module] namespace
    # @param [Symbol] collection The collection name
    # @param [Array<Symbol>] i18n_scope
    # @param [String, Symbol] predicates Include {Predicates} for enumerated attribute
    # @param [String, Symbol] scopes Include {Scopes} for enumerated attribute
    # @param [Hash<Symbol=>Hash>] options Enumerated values and options
    ::Enum = lambda do |namespace, collection, i18n_scope: nil, **options|
      i18n_scope ||= namespace unless namespace == Object
      predicates_for, scopes_for = options.extract!(:predicates, :scopes).values
      const = Inflector.camelize(collection)
      enum  = ::Class.new(::Piktur::Support::Enum) do
        enum collection, i18n_scope: i18n_scope, **options
      end

      namespace.const_set(const, enum)

      namespace.include enum.predicates(predicates_for) if predicates_for
      namespace.include enum.scopes(scopes_for) if scopes_for
      true
    end

    # Enum maps static values and translation to a developer friendly identifier.
    class Enum

      I18N_NAMESPACE = :enum

      DUPLICATE_KEY_MSG = <<~MSG
        Key %{key} already defined.
      MSG

      DUPLICATE_VALUE_MSG = <<~MSG
        Value %{value} already defined. Provide a unique value for "%{key}".
      MSG

      NOT_FOUND_MSG = <<~MSG
        Value "%{value}" not in %{enum}.
      MSG

      # Immutable object provides consistent representation of an enumerated value.
      #
      # @!attribute [r] key
      #   @return [Symbol]
      # @!attribute [r] value
      #   @return [Object]
      # @!attribute [r] default
      #   @return [Boolean]
      # @!attribute [r] i18n_scope
      #   @return [Array<Symbol>]
      # @!attribute [r] meta
      #   @return [Hash, nil]
      class Value

        attr_reader :key, :value, :matcher, :i18n_scope, :meta

        def initialize(key:, value:, i18n_scope:, default: false, meta: nil)
          @key        = key.to_sym
          @matcher    = /\A#{key}\Z/
          @value      = value
          @default    = default
          @i18n_scope = i18n_scope
          @meta       = meta&.freeze
          freeze
        end

        def as_json(**); value; end

        # @param [Hash] options
        # @return [String]
        def human(**options); ::I18n.t(@key, scope: i18n_scope, **options); end

        # @return [String]
        def to_s; human; end

        # @return [Integer]
        def to_i; value; end

        # @return [Boolean]
        def default?; @default; end # rubocop:disable TrivialAccessors

        # @example
        #   Enum[Object, :colours, red: { value: 0 }, green: { value: 1 }]
        #   Colours[:red] == Colours[:red] # => true
        #   Colours[:red] == 'red'         # => true
        #   Colours[:red] == :red          # => true
        #   Colours[:red] == :green        # => false
        #   Colours[:red] == 0             # => true
        #   Colours[:red] == 1             # => false
        # @return [Boolean]
        def eql?(other)
          return super if other.is_a?(Value)
          return false if defined?(::Dry::Core::Constants::Undefined) &&
              other == ::Dry::Core::Constants::Undefined

          value == other || key == other || match?(other)
        end
        alias == eql?

        # Implement equality operator so that Enum::Value may be used within in case statements.
        # @example
        #   gender = :male
        #
        #   case gender
        #   when Genders[:male]   then 'blue'
        #   when Genders[:female] then 'red'
        #   else
        #     'black'
        #   end
        def ===(other)
          return self == other if other.is_a?(Value)
          value == other || key == other
        end

        # @example
        #   Enum[Object, :colours, red: { value: 0 }, green: { value: 1 }]
        #   Colours[:red] =~ 'red'  # => true
        #   Colours[:red] == :red   # => true
        #   Colours[:red] == 0      # => false
        # @return [Boolean]
        def match?(other)
          return false unless other.respond_to?(:match?)
          other.match?(matcher)
        end
        alias =~ match?

      end

      # @example
      #   class Genders < Enum
      #     enum  :genders,
      #           nil:        { value: 0, default: true },
      #           male:       { value: 1 },
      #           female:     { value: 2 },
      #           non_binary: { value: 3 }
      #   end
      #
      #   Genders[1]          # => <Piktur::Support::Enum::Value key=:male value=1>
      #   Genders[:male]      # => <Piktur::Support::Enum::Value key=:male value=1>
      #   Genders.male        # => 1
      #   Genders.male(false) # => <Piktur::Support::Enum::Value key=:male value=1>
      class << self

        attr_accessor :collection, :mapping, :keys, :values

        # @param [Symbol] collection
        # @param [Array<Symbol>] i18n_scope
        # @param [Hash] enumerated
        # @return [void]
        def enum(collection, i18n_scope: nil, **enumerated)
          @collection, @mapping = collection.to_sym, {}
          @i18n_scope = _i18n_scope(i18n_scope)
          enumerated.each { |key, options| declare!(key, i18n_scope: @i18n_scope, **options) }
          @keys, @values = mapping.keys.freeze, mapping.values.freeze
          @mapping.freeze
          true
          register_type(@_key)
        # @param [Symbol, String, Integer] input
        # @return [Value]
        def call(input)
          find(input) || default
        end

        # @return [Dry::Types::Constructor]
        def type
          Types[@_key]
        end

        # @!method find
        # @!method find_by_key
        # @!method find_by_value
        # @param [String, Symbol, Integer] value
        # @return [Enum::Value]

        def find(value); value && (find_by_value(value) || find_by_key(value)); end

        def find!(value); find(value) || not_found!(value); end
        alias [] find!

        def find_by_key(key); values.find { |obj| obj == key }; end

        def find_by_value(value); values.find { |obj| obj == value }; end

        # @!method []
        # @!method find!
        # @!method find_by_key!
        # @!method find_by_value!
        # @param [Object] value
        # @raise [ArgumentError]
        # @return [Enum::Value]

        def find_by_key!(key); key && find_by_key(key) || not_found!(value); end

        def find_by_value!(value); value && find_by_value(value) || not_found!(value); end

        # @return [Boolean]
        def include?(value); find(value).present?; end

        # @!attribute [r] default
        # @return [Enum::Value]

        # @return [Integer]
        # @return [nil] if default value not set
        def default_value; default&.value; end

        # @return [Integer]
        def size; values.size; end

        # @return [Array]
        def each(&block); mapping.each(&block); end

        # @return [Array]
        def select(&block); mapping.select(&block); end

        # @param [Array<Symbol>] args
        # @return [Array]
        def values_at(*args); mapping.values_at(*args); end

        # @return [Enumerator]
        def to_enum; mapping.enum_for; end

        # @return [Hash]
        def to_hash; mapping.transform_values { |v| v.value }; end
        alias to_h to_hash

        # @!method to_a
        #   @return [Array<Enum::Value>]
        alias to_a values

        # @return [String, Symbol] attribute
        # @return [Module]
        def predicates(attribute); Predicates[attribute, self]; end

        # @return [String, Symbol] attribute
        # @return [Module]
        def scopes(attribute); Scopes[attribute, self]; end

        private

          # @!method key()
          #   @return [Integer]
          # @!method key(false)
          #   @return [Value]

          # Register coercer with Piktur::Types container. Coercer WILL return {Value}
          # corresponding to input, otherwise default or nil.
          #
          # @param [String] key
          # @return [Dry::Types::Constructor]
          def register_type(key)
            ::Piktur::Types
              .register key,
                        ::Dry::Types['object'].constructor { |input| call(input) },
                        call:    false,
                        memoize: false
          end

          # * Store {Value} under `key`
          # * Define scoped `I18n` helper
          # * Define method for `key`
          # @return [void]
          def declare!(key, value:, **options)
            validate!((key = key.to_sym), value)
            obj = mapping[key] = Value.new(key: key, value: value, **options)

            return if key == :default # Prevent method override

            warn "Name Collision: method #{@collection}.#{key} is already defined, #{__FILE__}:#{__LINE__}" if
              singleton_class.method_defined?(key)

            define_singleton_method(key) { |cast = true| cast ? obj.value : obj }
          end

          def not_found!(value)
            raise ArgumentError, NOT_FOUND_MSG % { value: value, enum: @collection }
          end

          def validate!(key, value)
            raise ArgumentError, DUPLICATE_KEY_MSG % { key: key } if
              duplicate_key?(key)
            raise ArgumentError, DUPLICATE_VALUE_MSG % { key: key, value: value } if
              duplicate_value?(value)
            true
          end

          def duplicate_key?(value); mapping.key?(value); end

          def duplicate_value?(value); mapping.find { |_, obj| value == obj.value }; end

          def _i18n_scope(namespace)
            namespace ||= parent_name
            if namespace && namespace != Object
              namespace = Inflector.underscore(namespace.to_s).to_sym
            end
            [I18N_NAMESPACE, *namespace, @collection]
          end

      end

      # Enumerated attribute predicates
      # @example
      #   class Model
      #     ::Enum[
      #       self,
      #       :syntaxes,
      #       predicates: 'syntax',
      #       markdown: { value: 0, default: true },
      #       html: { value: 1 }
      #     ]
      #     ::ApplicationModel[self, :Document, %w(syntax)]
      #   end
      Predicates = lambda do |attribute, enum|
        Module.new do
          setter = "#{attribute}=" # [:[]=, attribute]
          define_method("default_#{attribute}!") { send setter, enum.default_value }

          enum.each do |key, obj|
            getter = attribute # [:[], attribute]
            define_method("#{key}?") { enum[key] == send(getter) }

            setter = "#{attribute}=" # [:[]=, attribute]
            define_method("#{key}!") { send setter, obj.value }
          end
        end
      end

      # Define ActiveRecord scope per enumerated value
      # @todo Allow custom scope block. Enumerable attributes may be nested within a JSON column.
      # @example
      #   # Given DB table with column syntax
      #   class Record < ::ApplicationRecord
      #     ::Enum[
      #       self,
      #       :syntaxes,
      #       scopes: 'syntax',
      #       markdown: { value: 0, default: true },
      #       html: { value: 1 }
      #     ]
      #   end
      #
      #   # Given DB table with JSON column, provide JSON path as an Array to `:scopes` option.
      #   class Record < ::ApplicationRecord
      #     ::Enum[
      #       self,
      #       :syntaxes,
      #       scopes: %w(data branch syntax),
      #       markdown: { value: 0, default: true },
      #       html: { value: 1 }
      #     ]
      #   end
      #
      #   Record.find_by_syntax(0) # => ActiveRecord_Relation
      #   Record.markdown          # => ActiveRecord_Relation
      #   Record.html              # => ActiveRecord_Relation
      Scopes = lambda do |path, enum|
        Module.new do
          # Use define_singleton_method so that lambda context accessible
          define_singleton_method(:included) do |base|
            m = "find_by_#{scope_name(enum.collection, plural: false)}"
            base.scope m, ScopeBuilder.(base, path)

            enum.each do |key, obj|
              base.scope scope_name(key), ScopeBuilder.(base, path, obj.value)
            end
          end

          def self.scope_name(value, plural: true)
            plural ? Inflector.pluralize(value) : Inflector.singularize(value)
          end
          private_class_method :scope_name

        end
      end

      class ScopeBuilder

        # @return [Proc]
        def self.call(*args)
          new(*args).query
        end

        # @param [ApplicationRecord] klass
        # @param [String, Symbol, Array<String, Symbol>] path
        # @param [Integer] value
        def initialize(klass, path, value = nil)
          @klass = klass
          @path  = path
          @value = value
        end

        # @return [Proc]
        def query
          build_expression
        end

        private

          # Build query condition based on @path
          # @return [Arel::Attributes::Attribute]
          def build_expression
            @column, *@path, @property = @path
            # If @path is an Array,
            #   build JSON expression to traverse path
            #     compare nested property value to other
            if @property
              expression = get_jsonb_property
              if @value
                other = @value.to_json
                -> { where expression.eq(other) }
              else
                ->(other) { where expression.eq(other.to_json) }
              end
            else
              expression = @klass.table[@column]
              if @value
                other = @value.to_json
                -> { where expression.eq(other) }
              else
                ->(other) { where expression.eq(other) }
              end
            end
          end

          def typecast_for_database(value)
            @column.typecast_for_database(value)
          end

          def get_jsonb_property # rubocop:disable AccessorMethodName
            @klass
              .table[@column]
              .jsonb_get_path(*@path, @property)
              # .jsonb_get(@property)
          end

      end

    end

  end

end
