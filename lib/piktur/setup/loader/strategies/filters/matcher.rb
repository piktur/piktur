# frozen_string_literal: true

# rubocop:disable UncommunicativeMethodParamName

module Piktur

  module Loader

    # @see https://bitbucket.org/piktur/piktur_core/src/master/benchmark//pattern_matching.rb
    #   ::Benchmark.fnmatch_vs_match_combined
    #
    # @example
    #   Matcher['models', 'repositories']
    #   Matcher[Piktur.component_types, glob: true]
    #   Matcher[Piktur.component_types, glob: true, path: Dir.pwd]
    module Matcher

      module_function

      # @param [String] input The base string
      # @param [Boolean] glob
      #
      # @yieldparam [Array] arr The singular and plural inflections of `input`
      #
      # @return [Regexp]
      # @return [String] if glob true, returns a glob pattern
      def call(input, glob: false, path: nil, &block)
        a, b = inflections(input)

        if block_given?
          instance_exec([a, b], &block)
        elsif glob
          Glob[a, b, path: path]
        else
          Regexp[a, b]
        end
      end

      # @return [Array(String, String)] The singular and plural inflections of `input`
      def inflections(input)
        [Inflector.singularize(input), Inflector.pluralize(input)]
      end

      # @see https://bitbucket.org/piktur/piktur_core/src/master/benchmark//pattern_matching.rb
      #
      # @param [Array<String, Symbol>] arr
      # @param [Hash] options
      # @option options [Boolean] :glob (false)
      #
      # @yieldparam [Array] arr The singular and plural inflections for each
      #
      # @return [String] if glob true
      # @return [Regexp] if glob false
      def combine(arr, glob: false, &block)
        arr = arr.map { |input| inflections(input) }

        if block_given?
          instance_exec(arr, &block)
        elsif glob
          arr.map { |inflections| Glob[*inflections] }
        else
          Regexp.combine(arr)
        end
      end

      # @param [String] a The singular form
      # @param [String] b The plural form
      #
      # @return [Array<(String, String, String)>]
      def intersect(a, b)
        return [a, nil, nil] if a == b

        len = a.size
        return [a, nil, b[len..-1]] if b[len - 1] == a[-1]

        a.each_char.with_index do |char, i|
          break([ # rubocop:disable MultilineIfModifier
            a[0..(i - 1)], # The characters up to the divergence of `a` and `b`
            a[i..-1],  # The remaining characters of `a` after the divergence or `nil`
            b[i..-1]   # and for `b`
          ]) if char != b[i]
        end
      end

      # :nodoc
      module Glob

        # @return [String]
        WRAP_L = '**/{'

        # @return [String]
        WRAP_R = '}*'
        private_constant :WRAP_L, :WRAP_R

        # @return [String]
        SUB = '%s'

        # @return [String]
        DIR_PATTERN = '**'

        # @return [String]
        FILE_PATTERN = '*.rb'

        # @return [String]
        DEFAULT_PATTERN = '{*,**/*}.rb'

        # @return [String]
        INDEX_PATTERN = '%s.rb'

        # @return [String]
        NAMESPACE_PATTERN = '{%1$s,%1$s/**/*}.rb'

        # @return [String]
        SCOPED_TYPE_PATTERN = '%s/%s{*,**/*}.rb'

        # @return [String]
        UNSCOPED_TYPE_PATTERN = '**/%s{*,**/*}.rb'

        module_function

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
        def [](a, b, path: nil)
          glob = format(SCOPED_TYPE_PATTERN, SUB, Matcher.intersect(a, b)[0])
          path ? "#{path}/#{glob}" : glob
        end

      end

      # :nodoc
      module Regexp

        # @return [String]
        WRAP_L = "[#{::File::SEPARATOR}\.]"

        # @return [String]
        WRAP_R = "(?:#{WRAP_L}|$)"
        private_constant :WRAP_L, :WRAP_R

        # @return [Regexp]
        BASENAME_MATCHER = /\w+$/

        # @return [Regexp]
        LEADING_SLASH_MATCHER = ::Regexp.new "^#{::File::SEPARATOR}"

        module_function

        # @example
        #   to_regex('model', 'models')            # => Regexp
        #   to_regex('repository', 'repositories') # => Regexp
        #   to_regex('fish', 'fish')               # => Regexp
        #
        # @param [String] a The singular form
        # @param [String] b The plural form
        #
        # @return [Regexp]
        def [](a, b)
          ::Regexp.new [WRAP_L, *diff(a, b), WRAP_R].join
        end

        # Returns an Array containing:
        #   1. The matching segment of a and b
        #   2. The diff of a and b wrapped in a non-capturing Regexp group unless a == b
        #
        # @param [String] a The singular form
        # @param [String] b The plural form
        #
        # @return [Array<String>]
        def diff(a, b)
          match, a, b = Matcher.intersect(a, b)
          diff        = "(?:#{a}|#{b})" unless a == b
          [match, *diff]
        end

        # @param [Array<(String, String)>] arr The {Matcher.inflections} for each
        #
        # @return [Regexp]
        def combine(arr)
          arr = arr.map { |(a, b)| ['(?:', *diff(a, b), ')'].join }

          /#{[WRAP_L, '(?:', arr.join('|'), ')', WRAP_R].join}/
        end

      end

    end

  end

end
