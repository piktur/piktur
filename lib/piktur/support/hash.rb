# frozen_string_literal: true

module Piktur

  module Support

    module Hash

      # Flatten Hash keys recursively
      # @example
      #   src = {
      #     root: {
      #       branch:  { leaf: nil, leaf1: nil },
      #       branch1: { leaf: nil },
      #       branch2: {
      #         branch3: nil
      #       }
      #     }
      #   }.deep_stringify_keys!
      #
      #   flat_hash(src) # => {['root', 'branch', 'leaf'] => nil, ...}
      #   flat_hash(src).transform_keys! { |e| e.join('.') }
      #   # => {"root.branch.leaf"=>nil, ...}
      # @param [Hash] h original
      # @param [String] path
      # @param [Hash] a accumulator
      # @see http://stackoverflow.com/a/23861946
      # @return [Hash]
      def flat_hash(h, path = [], a = {})
        return a.update(path => h) unless h.is_a?(::Hash) && h.present?
        # [path, k].compact.join('.')
        h.each { |k, v| flat_hash(v, (path + [k]), a) }
        a
      end

    end

    ::Hash.extend(::Piktur::Support::Hash)

  end

end