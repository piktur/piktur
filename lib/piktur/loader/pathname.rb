# frozen_string_literal: true

module Piktur

  module Loader

    # Provides functions utilising String operations where std-lib `Pathname` functions would be
    # less performant.
    #
    # @example Utilising stdlib `Pathname`
    #   target = Pathname('app/concepts')
    #   path   = Pathname.pwd.join('app/concepts/catalogues/items/model.rb')
    #
    #   a = Piktur::Loader::Pathname.method(:rpartition).to_proc
    #   b = ->(path, target) {
    #     namespace = EMPTY_PATH.dup
    #     path.ascend do |p|
    #       break if p.basename == target.basename
    #       namespace = p.basename + namespace
    #     end
    #     namespace
    #   }
    #
    #   Warming up --------------------------------------
    #              a    47.883k i/100ms
    #              b     8.964k i/100ms
    #   Calculating -------------------------------------
    #              a    527.922k (± 3.2%) i/s -      2.681M in   5.084933s
    #              b     90.885k (± 1.8%) i/s -    457.164k in   5.031864s
    #   Comparison:
    #              a:   527922.1 i/s
    #              b:    90884.9 i/s - 5.81x  slower
    #
    # @example {.rpartition} vs {.right_of}
    #   require 'benchmark/ips'
    #   Benchmark.ips do |x |
    #     x.report('rpartition') { Path.rpartition(path, root)[-1] }
    #     x.report('right_of') { Path.right_of(path, root, relative: true) }
    #     x.compare!
    #   end
    #
    #   Warming up --------------------------------------
    #             rpartition    22.443k i/100ms
    #               right_of   104.072k i/100ms
    #   Calculating -------------------------------------
    #             rpartition    239.195k (± 1.9%) i/s -      1.212M in   5.068584s
    #               right_of      1.298M (± 1.6%) i/s -      6.557M in   5.051604s
    #   Comparison:
    #               right_of:  1298258.7 i/s
    #             rpartition:   239194.5 i/s - 5.43x  slower
      #
    module Pathname

      extend  ::ActiveSupport::Autoload
      include ::Piktur::Constants

      module_function

      # @!group Predicates

      # @param [Pathname] path
      #
      # @return [Boolean]
      def match?(path, other)
        _get_str(path).match?(other)
      end

      # @param [Pathname] path
      # @param [Pathname, String] other
      #
      # @return [Boolean]
      def start_with?(path, other)
        _get_str(path).start_with?(_get_str(other))
      end

      # @param [Pathname] path
      # @param [Pathname, String] other
      #
      # @return [Boolean]
      def end_with?(path, other)
        _get_str(path).end_with?(_get_str(other))
      end

      # @param [Pathname] path
      # @param [Pathname] other
      #
      # @return [true] if the last node in path a matches that of b
      def basename_match?(path, other)
        basename(path) == basename(other)
      end

      # @param [Pathname] path
      #
      # @return [true]
      def basename(path)
        _get_str(path)[Matcher::Regexp::BASENAME_MATCHER]
      end

      # @!endgroup

      # Returns the segment of `path` after `left` segment.
      # NOOP if `path` does not start with `left`
      #
      # @param [Pathname] path
      # @param [Pathname, String] left
      # @option options [Boolean] :relative (true)
      #
      # @return [String]
      def right_of(path, left, relative: true)
        path = _get_str(path); left = _get_str(left)
        return path unless path != left && start_with?(path, left)
        path[left.size + (relative ? 1 : 0)..-1]
      end
      alias relative_path_from_root right_of

      # Returns the segment of `path` before `right` segment.
      # NOOP if `path` does not end with `right`
      #
      # @param [Pathname] path
      # @param [Pathname, String] right
      # @option options [Boolean] :relative (true)
      #
      # @return [String]
      def left_of(path, right, relative: true)
        path = _get_str(path); right = _get_str(right)
        return path unless path != right && end_with?(path, right)
        path[0...-right.size - (relative ? 1 : 0)]
      end

      # Returns the `path` segments to the left and right of `target`
      #
      # @param [Pathname] path The absolute path
      # @param [Pathname] target The path segment to partition at
      #
      # @return [Array<(String, String, String)>]
      def rpartition(path, target)
        _get_str(path).rpartition(_wrap(_get_str(target)))
      end

      # Returns a copy of `path` replacing `match` with `other`
      #
      # @param [Pathname] path
      # @param [String] match
      # @param [String] other
      #
      # @return [String]
      def sub(path, match, other)
        _get_str(path)[match] = other
        path
      end

      # The String itself or, if `input` is a `Pathname`, its memoized String instance.
      #
      # @param [Pathname, String] input
      #
      # @return [String]
      def _get_str(input)
        input.is_a?(String) ? input : input.instance_variable_get(:@path)
      end
      private_class_method :_get_str

      # Removes the leading slash from input
      #
      # @param [String] input
      #
      # @return [String]
      def _relative(str)
        str.sub!(Matcher::Regexp::LEADING_SLASH_MATCHER, EMPTY_STRING)
        str
      end
      private_class_method :_relative

      # @see https://bitbucket.org/piktur/piktur_core/src/master/benchmark//pattern_matching.rb
      #   .string_wrap_conditional
      #
      # @param [String] str
      #
      # @return [String]
      def _wrap(str)
        @char  ||= ::File::SEPARATOR
        @lsub  ||= @char + '\1'
        @rsub  ||= @lsub.reverse

        str[/^\w/] = @char + str[0]  unless str.start_with?(@char)
        str[/\w$/] = str[-1] + @char unless str.end_with?(@char)
        str
      end
      private_class_method :_wrap

    end

  end

end
