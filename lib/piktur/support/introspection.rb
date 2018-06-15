# frozen_string_literal: true

module Piktur

  module Support

    # Optimised `Module` introspection algorithm.
    #
    # @example Usage
    #   Support.install(:module)
    #
    # @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/module/introspection.rb
    #
    module Introspection

      # @return [void]
      def self.install(*)
        ::Module.extend(self)
        true
      end

      # Returns all the parents of a Module from innermost to outermost.
      # The receiver is not included.
      #
      # @return [Array<Module>]
      def parents
        return @_parents if defined?(@_parents)

        @_parents = [Object]

        name
          .split('::')[0..-2]
          .inject(self) { |a, e| @_parents.unshift(a = a.const_get(e, false)); a }

        @_parents.freeze
      end

      # @return [Module]
      def parent
        parents[0]
      end

      # @return [String]
      def parent_name
        parent.name
      end

    end

  end

end
