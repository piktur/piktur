# frozen_string_literal: true

module Piktur

  module Support

    # Ruby core Hash extension
    #
    # @example Usage
    #   Support.install(:hash)
    module Hash

      def self.install(*)
        ::Hash.extend(self)
      end
      private_class_method :install

      # Provides an attr_reader like interface for Hash. ~3x faster than OpenStruct to initialize
      # and read.
      #
      # @example Benchmark
      #   module Benchmark
      #     def self.run(**options)
      #       require 'benchmark/ips'
      #       Benchmark.ips do |x|
      #         x.report('OpenStruct') do
      #           ostruct = OpenStruct.new
      #           ostruct['abc'] = 123
      #           ostruct[:xyz] = 123
      #           ostruct.abc
      #           ostruct.xyz
      #         end
      #
      #         x.report('WithAttrReader') do
      #           h = WithAttrReader.new
      #           h['abc'] = 123
      #           h[:xyz] = 123
      #           h.abc
      #           h.xyz
      #         end
      #
      #         x.compare!
      #       end
      #     end
      #   end
      #
      # @example
      #   obj = Struct.new
      #   obj['abc'] = 123
      #   obj.abc # => 123
      #
      class WithAttrReader < ::Hash

        # Recursively copy the hash structure to a new instance of WithAttrReader
        #
        # @param [Hash] object
        #
        # @return [WithAttrReader]
        def self.[](object, recursive: false)
          new.tap do |h|
            object.is_a?(::Hash) && object.each do |k, v|
              h[k] = recursive && # rubocop:disable MultilineTernaryOperator
                (v.is_a?(::Hash) || v.is_a?(::Array)) ? self[v, recursive: true] : v
            end
          end
        end

        private

          # @param [Symbol] method_name
          #
          # @return [Object]
          # @return [nil] if {#key} undefined
          def method_missing(method_name, *) # rubocop:disable MethodMissingSuper
            fetch(m = method_name[/\w+/]) { fetch(m.to_sym) { nil } }
          end

          # @param [Symbol] method_name
          #
          # @return [Boolean]
          def respond_to_missing?(method_name, *)
            method_name.match?(/\w$/) || super
          end

      end

      # @example Build nested hash from key array
      #   %w(1 2 3).reduce(h = {}) { |a, e| a[e] = {} }

      # Flatten Hash keys recursively
      #
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
      #
      # @param [Hash] h original
      # @param [String] path
      # @param [Hash] a accumulator
      #
      # @see http://stackoverflow.com/a/23861946
      #
      # @return [Hash]
      def flat_hash(h, path = [], a = {}) # rubocop:disable UncommunicativeMethodParamName
        return a.update(path => h) unless h.is_a?(::Hash) && h.present?

        # [path, k].compact.join('.')
        h.each { |k, v| flat_hash(v, (path + [k]), a) }
        a
      end

    end

  end

end
