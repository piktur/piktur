# frozen_string_literal: true

module Piktur

  module Support

    # @todo https://bitbucket.org/snippets/piktur/AeL8gx Example refactor
    #
    # Provides functions utilising String operations where std-lib `Pathname` functions would be
    # less performant.
    #
    # @example
    #   path = Pathname('app/concepts/users/relation.rb')
    #   partition(path) do |path|
    #     Inflector.constantize(const, camelize: trues) # => Users::Relation
    #   end
    #
    # @example
    #   model_paths = [Pathname('model_a.rb'), Pathname('model_b.rb')]
    #
    #   models = paths.map do
    #     partition(path, normalize: true) do |path|
    #       const = ::Inflector.classify(path)
    #       Inflector.constantize(const)
    #     end
    #   end
    #
    #   # You could build a JSON representation of the application schema
    #   Schema.call(models).to_json
    #   # => {
    #   #   "user": {
    #   #     "attribute": {
    #   #       "type": "String",
    #   #       "required": true
    #   #     }
    #   #   },
    #   #   "catalogueItems": { ... }
    #   # }
    #
    # {include:Pathname::Matcher}
    # {include:Pathname::Sorter}
    module Pathname

      extend  ::ActiveSupport::Autoload
      include ::Piktur::Constants

      autoload :Matcher
      autoload :Sorter

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
        _get_str(path)[Matcher::Regexp::BASENAME_MATCHER] ==
          _get_str(other)[Matcher::Regexp::BASENAME_MATCHER]
      end

      # @!endgroup

      # Returns the segment of `path` after `left` segment
      #
      # @param [Pathname] path
      # @param [Pathname, String] left
      #
      # @return [String]
      # @return [nil] if `path` does not start with `left`
      def right_of(path, left, relative: true)
        return unless path != left && start_with?(path, left)
        _get_str(path)[_get_str(left).size + (relative ? 1 : 0)..-1]
          # .send(relative ? :tap : :itself) { |str| _relative(str) }
      end

      # Returns the segment of `path` before `right` segment
      #
      # @param [Pathname] path
      # @param [Pathname, String] right
      # @option options [Boolean] :relative (true)
      #
      # @return [String] The truncated path
      # @return [nil] if `path` does not end with `right`
      def left_of(path, right, relative: true)
        return unless path != right && end_with?(path, right)
        _get_str(path)[0...-_get_str(right).size - (relative ? 1 : 0)]
          # .send(relative ? :tap : :itself) { |str| _relative(str) }
      end

      # Returns the `path` segments to the left and right of `target` if target include
      #
      # @param [Pathname] path The absolute path
      # @param [Pathname] target The path segment to partition at
      #
      # @yieldparam [String] the absolute root path
      # @yieldparam [String] the relative path from {#target}
      #
      # @return [Array<(String, String)>]
      def partition(path, target)
        return if path == target

        path   = path.to_s
        target = _wrap(target.to_s)

        if path.index(target)
          root, _, path = path.partition(target)
        else
          root = '/'
        end

        block_given? ? yield(root, path) : [root, path]
      end

      # Returns a copy of `path` replacing `match` with `other`
      #
      # @param [Pathname] path
      # @param [String] match
      # @param [String] other
      #
      # @return [String]
      def sub(path, match, other)
        path.to_s[match] = other
        path
      end

      # @example Less performant implementation utilising stdlib `Pathname`
      #   #   Warming up --------------------------------------
      #   #              a    47.883k i/100ms
      #   #              b     8.964k i/100ms
      #   #   Calculating -------------------------------------
      #   #              a    527.922k (± 3.2%) i/s -      2.681M in   5.084933s
      #   #              b     90.885k (± 1.8%) i/s -    457.164k in   5.031864s
      #   #
      #   #   Comparison:
      #   #              a:   527922.1 i/s
      #   #              b:    90884.9 i/s - 5.81x  slower
      #
      #   namespace = EMPTY_PATH.dup
      #   path.ascend do |p|
      #     break if p.basename == target.basename
      #     namespace = p.basename + namespace
      #   end
      #   namespace
      #
      # @param see (.partition)
      #
      # @return [Pathname] The relative path from {#target}
      def relative_path_from_target(path, target)
        partition(path, target) { |_, path| Pathname(_relative(path)) } # rubocop:disable ShadowingOuterLocalVariable
      end

      # @param [Pathname] root
      # @param [Pathname] path
      #
      # @return [String]
      def relative_path_from_root(path, root)
        right_of(path, root, relative: true)
      end

      # @return [Pathname] The absolute path of {#target} root
      def absolute_path_of_root(*args)
        partition(*args) { |root, _| Pathname(root) }
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

      # @see https://bitbucket.org/piktur/piktur_core/src/master/spec/benchmark/pattern_matching.rb
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
