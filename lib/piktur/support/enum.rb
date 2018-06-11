# frozen_string_literal: true

# rubocop:disable FormatString, MemoizedInstanceVariableName

module Piktur

  module Support

    # Enum maps static values and translation to a developer friendly identifier.
    #
    # @see https://bitbucket.org/piktur/piktur/issues/1/optimise-piktur-support-enum
    #
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
    class Enum

      I18N_NAMESPACE = :enum

      NonNumericValuerError = Class.new(StandardError)

      ENUM_FROZEN_MSG = "can't modify frozen %s"

      DUPLICATE_KEY_MSG = <<~MSG
        Key %{key} already defined.
      MSG

      DUPLICATE_VALUE_MSG = <<~MSG
        Value %{value} already defined. Provide a unique value for "%{key}".
      MSG

      NOT_FOUND_MSG = <<~MSG
        Value "%{value}" not in %{enum}.
      MSG

      NAME_COLLISION_MSG = <<~MSG
        Name Collision: method "%{m}" is already defined. %{file}:%{line}
      MSG

      NON_NUMERIC_VALUE_MSG = <<~MSG
        Value %{value} MUST BE numeric.
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
        #
        # @return [String]
        def human(**options); ::I18n.t(@key, scope: i18n_scope, **options); end

        # @return [String]
        def to_s; key.to_s; end

        # @return [Symbol]
        def to_sym; key; end

        # @return [Integer]
        def to_i; value; end

        # @return [Boolean]
        def default?; @default; end # rubocop:disable TrivialAccessors

        # @example
        #   ::Piktur::Types.Enum(Object, :colours, red: { value: 0 }, green: { value: 1 })
        #   Colours[:red] == Colours[:red] # => true
        #   Colours[:red] == 'red'         # => true
        #   Colours[:red] == :red          # => true
        #   Colours[:red] == :green        # => false
        #   Colours[:red] == 0             # => true
        #   Colours[:red] == 1             # => false
        #
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

        # @return [String]
        def inspect
          "<Enum::Value #{key}=#{value} default=#{@default}>"
        end

      end

      class << self

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
        # @param [Symbol] name The collection name
        # @param [Array<Symbol>] i18n_scope
        # @param [String, Symbol] predicates Include {Predicates} for enumerated attribute
        # @param [String, Symbol] scopes Include {Scopes} for enumerated attribute
        # @param [Hash<Symbol=>Hash>] options Enumerated values and options
        #
        # @option options [Symbol] :predicates (nil) the enumerated attribute name
        # @option options [Symbol] :scopes (nil) the enumerated attribute name
        #
        # @return [Object] the immutable Enum instance
        def call(namespace, name, i18n_scope: nil, **options, &block)
          i18n_scope ||= namespace unless namespace == Object
          builders = options.extract!(:predicates, :scopes).values
          enum = new(name, i18n_scope: i18n_scope, **options, &block)
          enum.finalize!(namespace, *builders)
        end
        alias [] call

      end

      attr_reader :name, :mapping, :keys, :values

      # @param [Symbol] name
      # @param [Array<Symbol>] i18n_scope
      # @param [Hash] enumerable
      # @yieldparam [Enum] enum
      # @return [void]
      def initialize(name, i18n_scope: nil, **enumerable)
        @name = name.to_sym
        i18n_scope(i18n_scope)
        map(enumerable)
        default; const; key; to_s # memoize

        yield(self) if block_given?
      end

      # @param [Symbol, String, Integer] input
      # @return [Value]
      def call(input)
        find(input) || default
      end

      # @return [Dry::Types::Constructor]
      def type
        Types[key]
      end

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

      # @return [String]
      def human(*); Support::Inflector.humanize(name); end

      # @return [String]
      def to_s; name.to_s; end

      # @return [Hash]
      def to_hash; h = {}; each { |v| h[v.key] = v.value }; h; end
      alias to_h to_hash

      # @!method to_a
      #   @return [Array<Enum::Value>]
      alias to_a values

      # @param [String, Symbol] attribute
      #
      # @return [Module]
      def predicates(attribute); Predicates[attribute, self]; end

      # @param [String, Symbol] attribute
      #
      # @return [Module]
      def scopes(attribute); Scopes[attribute, self]; end

      # Finalizes the instance registers it with the application container and extends
      # the parent `namespace` with the requested helper modules if requested.
      #
      # @param [Module] namespace
      # @param [String, Symbol] predicates Include {Predicates} for enumerated attribute
      # @param [String, Symbol] scopes Include {Scopes} for enumerated attribute
      #
      # @raise [RuntimeError]
      #
      # @return [void]
      def finalize!(namespace, predicates = nil, scopes = nil)
        raise(::RuntimeError, ENUM_FROZEN_MSG % inspect) if frozen?

        # namespace.const_set(@_const, self)
        register_container_item if defined?(::Piktur::Container)
        register_type if defined?(::Piktur::Types)

        namespace.include(self.predicates(predicates)) if predicates
        namespace.include(self.scopes(scopes)) if scopes
        freeze
      end

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

        # Register the instance with the application container.
        #
        # @note This is preferrable to constant assignment as it avoids potential naming conflicts
        #   with the parent module.
        #
        # @return [void]
        def register_container_item
          ::Piktur.container.register(key, self)
        end

        # Register coercer with {Piktur::Types} container. Coercer WILL return {Value}
        # corresponding to input, otherwise default or nil.
        #
        # Coercer SHOULD BE used when presenting enumerated value for human consumption or when
        # validating input.
        #
        # @param [String] key
        #
        # @return [Dry::Types::Constructor]
        def register_type
          ::Piktur::Types
            .register key,
                      ::Dry::Types['object'].constructor { |input| call(input) },
                      call:    false,
                      memoize: false
        end

        # * Store {Value} under `key`
        # * Define scoped `I18n` helper
        # * Define method for `key`
        #
        # @return [void]
        def declare!(key, value: nil, **options)
          validate!((key = key.to_sym), value)
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

        # @return [String] the camelized constant name
        def const
          @_const ||= Inflector.camelize(name).freeze
        end

        # @return [String] the container key
        def key
          @_key ||= @i18n_scope.join(separator).tr('/', separator).freeze
        end

        # @return [String] the container key separator
        def separator
          defined?(::Piktur::Container) && ::Piktur::Container.config.namespace_separator || '.'
        end

        # @param [Numeric] value
        #
        # @raise [ArgumentError] if value missing
        def not_found!(value)
          raise ::ArgumentError, NOT_FOUND_MSG % { value: value, enum: name }
        end

        # @param [Symbol] key
        # @param [Numeric] value
        #
        # @raise [ArgumentError] if value missing
        def validate!(key, value)
          # @note REDUNDANT - It's not possible to define a duplicate key within a Hash
          # raise ::ArgumentError, DUPLICATE_KEY_MSG % { key: key } if
          #   duplicate_key?(key)

          # @note REDUNDANT - Use the index of the Struct instance
          # raise ::ArgumentError, DUPLICATE_VALUE_MSG % { key: key, value: value } if
          #   duplicate_value?(value)

          # @note REDUNDANT - The index is numeric
          # raise NonNumericValuerError, NON_NUMERIC_VALUE_MSG % { value: value } unless
          #   value.is_a?(Numeric)

          true
        end

        # @return [Boolean]
        # def duplicate_key?(value); mapping.members.include?(value); end

        # @return [Boolean]
        # def duplicate_value?(value); mapping.find { |_, obj| value == obj.value }; end

        # @param [Module]
        #
        # @return [Array<Symbol>]
        def i18n_scope(namespace)
          if namespace && namespace != Object
            namespace = Inflector.underscore(namespace.to_s).to_sym
          end
          @i18n_scope = [I18N_NAMESPACE, *namespace, name].freeze
        end

      # Enumerated attribute predicates
      # @example
      #   class Model
      #     ::Piktur::Types.Enum(
      #       self,
      #       :syntaxes,
      #       predicates: 'syntax',
      #       markdown: { value: 0, default: true },
      #       html: { value: 1 }
      #     )
      #     ::ApplicationModel[self, :Document, %w(syntax)]
      #   end
      Predicates = lambda do |attribute, enum|
        Module.new do
          setter = "#{attribute}=".to_sym # [:[]=, attribute]
          getter = attribute.to_sym       # [:[], attribute]

          define_method("default_#{attribute}!".to_sym) { send(setter, enum.default_value) }

          enum.each do |obj|
            define_method("#{key}?".to_sym) { obj == send(getter) }
            define_method("#{key}!".to_sym) { send(setter, obj.value) }
          end
        end
      end

      # Define ActiveRecord scope per enumerated value
      # @todo Allow custom scope block. Enumerable attributes may be nested within a JSON column.
      # @example
      #   # Given DB table with column syntax
      #   class Record < ::ApplicationRecord
      #     ::Piktur::Types.Enum(
      #       self,
      #       :syntaxes,
      #       scopes: 'syntax',
      #       markdown: { value: 0, default: true },
      #       html: { value: 1 }
      #     )
      #   end
      #
      #   # Given DB table with JSON column, provide JSON path as an Array to `:scopes` option.
      #   class Record < ::ApplicationRecord
      #     ::Piktur::Types.Enum(
      #       self,
      #       :syntaxes,
      #       scopes: %w(data branch syntax),
      #       markdown: { value: 0, default: true },
      #       html: { value: 1 }
      #     )
      #   end
      #
      #   Record.find_by_syntax(0) # => ActiveRecord_Relation
      #   Record.markdown          # => ActiveRecord_Relation
      #   Record.html              # => ActiveRecord_Relation
      Scopes = lambda do |path, enum|
        Module.new do
          # Use define_singleton_method so that lambda context accessible
          define_singleton_method(:included) do |base|
            m = "find_by_#{scope_name(enum.name, plural: false)}"
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

  # @return [Piktur::Support::Enum] the registered enum instance
  def self.enum(key); container["#{Support::Enum::I18N_NAMESPACE}.#{key}"]; end

end

# Enum = Piktur::Support::Enum
