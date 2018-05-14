# frozen_string_literal: true

require 'fast_underscore'
require 'active_support/inflector'

ActiveSupport::Inflector.inflections(:en) do |inflector|
  inflector.acronym 'DSL'
  inflector.acronym 'API'
  inflector.acronym 'JSON'
  inflector.acronym 'JSONB'
  inflector.acronym 'SQL'
  inflector.acronym 'PostgreSQL'
  inflector.acronym 'XML'
  inflector.acronym 'YAML'
  inflector.acronym 'HTTP'
  inflector.acronym 'HTTPS'
  inflector.acronym 'RESTful'
  inflector.acronym 'JWT'

  inflector.plural(/(ba)(se)\Z/i, '\1\2s')
  inflector.singular(/(ba)(sis|ses)\Z/i, '\1se')

  inflector.uncountable %w(root)
end

module Piktur

  module Support

    # @example
    #   Object.extend Inflector
    module Inflector

      CAMELIZED_MATCHER = /[A-Z\-:]/ # /[A-Z-]|::/
      private_constant :CAMELIZED_MATCHER

      class << self

        def install(*)
          ::Object.const_set(:Inflector, self)
        end
        private :install

        include ::ActiveSupport::Inflector

        # @note FastUnderscore CAN NOT handle Symbol input.
        # @param [String, Symbol] input
        # @return [String]
        def underscore(input)
          return input unless input.match?(CAMELIZED_MATCHER)
          ::FastUnderscore.underscore(input.to_s)
        end

        # @see https://ruby-doc.org/core-2.5.0/Module.html#method-i-const_defined-3F
        #   NameSpace.const_defined?('Child', false) # disable inherited lookup
        #
        # Find constant named `:const` within `:scope` only.
        # The constant SHOULD be in CamelCase but will be transformed if option :camelize true.
        # If `:scope` not given, the lookup is performed within top-level namespace.
        #
        # @example
        #   module Tree
        #     safe_constantize(:Branch)        # => Tree::Branch
        #     safe_constantize('Branch::Leaf') # => Tree::Branch::Leaf
        #     safe_constantize('Branch::Leaf') # => Tree::Branch::Leaf
        #   end
        #
        # @param [String, Symbol] const The camel cased constant
        # @param [Class, Module] scope The namespace to search within
        # @option options [Boolean] camelize Perform transformation
        #
        # @return [Class, Module]
        # @return [nil] if constant not defined in scope
        def constantize(const, scope = ::Object, camelize: false)
          camelize && (const = camelize(const))
          constantize!(const, scope) if scope.const_defined?(const, false)
        end
        alias safe_constantize constantize

        # Find constant named `:const` within `:scope` only.
        # The constant MUST be CamelCased; the input will not be transformed.
        # If `:scope` not given, the lookup is performed within top-level namespace.
        #
        # @example
        #   module Tree
        #     Age = 1_000_000
        #   end
        #   Tree.constantize!('Age') # => 1_000_000
        #   Tree.constantize!('Ag')  # => NameError: uninitialized constant Ag
        #   constatize!('Tree::Age') # => 1_000_000
        # @param [String, Symbol] const The camel cased constant
        # @param [Class, Module] scope The namespace to search within
        #
        # @raise [NameError] if constant not in `scope`
        # @return [Class, Module]
        def constantize!(const, scope = ::Object)
          scope.const_get(const, false)
        end

        # @example
        #   segments = %w(church priest clergy)
        #   Inflector.join *segments, path: true      # => Church::Priest::Clergy
        #   Inflector.join *segments, path: false     # => ChurchPriestClergy
        #   Inflector.join *segments, path: false, transform: :underscore # => church_priest_clergy
        def join(*args, path: true, transform: :camelize)
          separator = path ? '/' : '_'
          send(transform, args.join(separator))
        end

      end

    end

  end

end
