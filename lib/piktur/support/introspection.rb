# frozen_string_literal: true

require 'active_support/core_ext/module/introspection'

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
        ::Module.prepend(self)

        true
      end

      # Returns all the parents of a Module from innermost to outermost.
      # The receiver is not included.
      #
      # @return [Array<Module>]
      def parents # rubocop:disable MethodLength
        return @_parents if defined?(@_parents)
        return @_parents = [::Object] if singleton_class?

        @_parents = []

        to_s.split('::').tap do |arr|
          arr.pop

          until arr.empty?
            @_parents << ::Object.const_get(arr.join('::'), false)
            arr.pop
          end

          @_parents << ::Object
        end

        @_parents.freeze
      end

      # @return [Module]
      def parent
        parents[0]
      end

      # @return [String]
      def parent_name
        return EMPTY_STRING if parent == ::Object
        parent.to_s
      end

    end

  end

end
