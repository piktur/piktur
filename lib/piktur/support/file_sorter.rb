# frozen_string_literal: true

module Piktur

  module Support

    # @example
    #   ns    = 'app/concepts/users'
    #   files = %W(#{ns}/repositories/variant.rb #{ns}/repository.rb)
    #   FileSorter[files, :repository] # => ['ns/repository.rb', 'ns/repositories/variant.rb']
    module FileSorter

      # @return [Regexp]
      PRIMARY_MATCHER   = /\w+.rb$/
      # @return [Regexp]
      SECONDARY_MATCHER = /#{Concepts::Naming::DEFAULT_VARIANT}.rb$/

      module_function

      # @param [Array<String>] files
      # @param [Symbol, String] var Typically an application component type
      #
      # @return [Array<String>]
      def call(files, var)
        arr = ::Array.new(2, nil)
        files.each do |f|
          (arr[0] ||= primary(f, var)) || (arr[1] ||= secondary(f)) || (arr << f)
        end
        arr.compact!
        arr
      end

      # @param [String] file
      # @param [String, Symbol] var Typically an application component type
      #
      # @return [nil] if `file` DOES NOT end with {Piktur::Concepts::Naming::DEFAULT_VARIANT}
      def primary(file, var)
        file if file[PRIMARY_MATCHER] == "#{var}.rb"
      end

      # @param [String] file
      #
      # @return [nil] if `file` DOES NOT end with {Piktur::Concepts::Naming::DEFAULT_VARIANT}
      def secondary(file)
        file if file[SECONDARY_MATCHER]
      end

    end

  end

end
