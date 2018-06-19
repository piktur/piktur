# frozen_string_literal: true

module Piktur

  module Loader

    # @example
    #   paths = ["<ns>/repositories/variant.rb", "<ns>/repository.rb"]
    #   Sorter[paths, :repository]
    #   # => [
    #   #   Pathname('<ns>/repository.rb'),
    #   #   Pathname('<ns>/repositories/variant.rb')
    #   # ]
    module Sorter

      # @return [String]
      DEFAULT_VARIANT = defined?(Concepts) ? Concepts::Naming::DEFAULT_VARIANT : 'default'
      # @return [Regexp]
      PRIMARY_MATCHER   = /\w+\.rb$/
      # @return [Regexp]
      SECONDARY_MATCHER = ::Regexp.new "#{DEFAULT_VARIANT}\.rb$"

      module_function

      # @param [Array<String>] paths The list of components paths to sort
      # @param [Symbol, String] variant The name of the primary component definition or a variant
      #
      # @return [Array<String>]
      def call(paths, variant)
        arr = ::Array.new(2, nil)
        paths.each do |p|
          (arr[0] ||= primary(p, variant)) || (arr[1] ||= secondary(p)) || (arr << p)
        end
        arr.compact!
        arr
      end

      # @param [String] path
      # @param [String, Symbol] variant The name of the primary component definition or a variant
      #
      # @return [nil] if `file` DOES NOT end with {Concepts::Naming::DEFAULT_VARIANT}
      def primary(path, variant)
        path if path[PRIMARY_MATCHER] == "#{variant}.rb"
      end

      # @param [Pathname] path
      #
      # @return [nil] if `file` DOES NOT end with {Concepts::Naming::DEFAULT_VARIANT}
      def secondary(path)
        path if path[SECONDARY_MATCHER]
      end

    end

  end

end
