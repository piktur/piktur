# frozen_string_literal: true

# rubocop:disable UncommunicativeMethodParamName

module Piktur

  module Support

    # @example
    #   FileMatcher['models', 'repositories']
    #   FileMatcher[*Concepts::COMPONENTS, glob: true]
    #   FileMatcher[*Concepts::COMPONENTS, glob: true, path: Dir.pwd]
    module FileMatcher

      module_function

      # @param [Array<Symbol, String>] var A list of variables
      # @param [Boolean] glob
      #
      # @return [Array<Regexp>]
      def call(*args, glob: false, path: nil)
        arr = []
        args.each do |e|
          a = Inflector.singularize(e)
          b = Inflector.pluralize(e)
          arr << (glob ? to_glob(a, b, path: path) : to_regex(a, b))
        end
        return arr if glob
        arr << combined_regex(arr)
      end

      # @example
      #   to_glob('model', 'models')              # => "**/model{*,**/*}.rb"
      #   to_glob('repository', 'repositories')   # => "**/repositor{*,**/*}.rb"
      #   to_glob('thing', 'things', path: 'dir') # => "dir/**/thing{*,**/*}.rb"
      #
      # @see https://bitbucket.org/snippets/piktur/aeGpzM
      #
      # @param [String] a The singular form
      # @param [String] b The plural form
      #
      # @return [String]
      def to_glob(a, b, path: nil)
        glob = "**/#{insersect(a, b)}{*,**/*}.rb"
        path ? "#{path}/#{glob}" : glob
      end

      # @example
      #   to_regex('model', 'models') # => /model(|s)[\/\.]/
      #   to_regex('repository', 'repositories') # => /repositor(y|ies)[\/\.]/
      #   to_regex('fish', 'fish') # => /sheep[\/\.]/
      #
      # @param [String] a The singular form
      # @param [String] b The plural form
      #
      # @return [Regexp]
      def to_regex(a, b)
        intersection = insersect(a, b)
        rng          = intersection.size..-1
        parts        = [bound = "[#{::File::SEPARATOR}\.]", intersection, bound]
        parts.insert(2, "(#{a[rng]}|#{b[rng]})") if a != b

        ::Regexp.new parts.join
      end

      # @param [Array<Regexp>] arr
      #
      # @return [Regexp]
      def combined_regex(arr)
        /.*(#{arr.join('|')})/
      end

      # @param [String] a The singular form
      # @param [String] b The plural form
      #
      # @return [String] the characters up to the difference of a and b
      def insersect(a, b)
        str = ::String.new
        a.each_char.with_index do |char, i|
          break(str) if char != b[i]
          str << char
        end
      end

    end

  end

end
