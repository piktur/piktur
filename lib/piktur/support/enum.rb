# frozen_string_literal: true

module Piktur::Support # rubocop:disable ClassAndModuleChildren

  # Enum maps static values and translation to a developer friendly identifier.
  #
  # @see https://bitbucket.org/piktur/piktur/issues/1/optimise-piktur-support-enum
  #
  # @example
  #   class WithEnum
  #     # The enumerable attribute
  #     attr_accessor :enumerable
  #
  #     # Provide name, options and enumerable values to the constructor.
  #     # Enumerated values may be declared within a block.
  #     Enum.new :enumerable, namespace: self do
  #       i18n_scope :other
  #       predicates :enumerable # Add predicate instance methods to `namespace`.
  #                              # Methods are named according to given attribute.
  #
  #       default :a           # Set the default value
  #       value   :b           # Define additional values
  #       value   :c, meta: {} # Store metadata with the value
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
  module Enum

    extend ::ActiveSupport::Autoload

    autoload :Attributes, 'piktur/support/enum/mixins/attributes'
    autoload :Constructor
    autoload :Config
    autoload :DSL
    autoload :Map
    autoload :Plugins
    autoload :Predicates, 'piktur/support/enum/mixins/predicates'
    autoload :Set
    autoload :Validator
    autoload :Value

    # @return [String]
    ENUM_FROZEN_MSG = %(can't modify frozen %s)
    private_constant :ENUM_FROZEN_MSG

    # @return [String]
    NOT_FOUND_MSG = %(Value "%{value}" not in %{enum}.)
    private_constant :NOT_FOUND_MSG

    extend Plugins

    class << self

      def new(*args, constructor: :set, **options, &block)
        case constructor
        when :set then Set.new(*args, options, &block)
        when :map then Map.new(*args, options, &block)
        end
      end

      # @return [Dry::Configurable]
      def config; Config.config; end

      # @return [void]
      def configure(&block); Config.configure(&block); end

      # @return [Object]
      def inflector; config.inflector; end

      # @return [Object]
      def container
        config.container.is_a?(Proc) ? config.container.call : config.container
      end

      # @return [Symbol, String]
      def i18n_namespace; config.i18n_namespace; end

      # @return [Validator]
      def validator; @validator ||= Validator.new; end

    end

  end

end
