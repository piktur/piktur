# frozen_string_literal: true

require 'dry/equalizer'

module Piktur

  # @see https://github.com/rom-rb/rom/blob/master/core/lib/rom/registry.rb
  class Registry

    include ::Enumerable
    include ::Dry::Equalizer(:elements)

    # @!attribute [r] elements
    #   @return [Hash] Internal hash for storing registry objects
    attr_reader :elements

    # @!attribute [r] cache
    #   @return [Cache] local cache instance
    attr_reader :cache

    def initialize(elements = {}, cache: Cache.new, **)
      @elements = elements
      @cache = cache
    end

    # @param [Registry] other
    #
    # @return [Registry]
    def merge(other)
      self.class.new(Hash(other), options)
    end

    # @return [Hash]
    def to_hash
      elements
    end

    # @return [Registry]
    def map(&block) # rubocop:disable UnusedMethodArgument
      new_elements = elements.each_with_object({}) do |(name, element), h|
        h[name] = yield(element)
      end

      self.class.new(new_elements, options)
    end

    # @yieldparam [Array<Symbol, Object>] element Element tuple
    #
    # @return [void]
    def each
      return to_enum unless block_given?
      elements.each { |element| yield(element) }
    end

    # @param [String, Symbol] name
    #
    # @return [Boolean]
    def key?(name)
      !name.nil? && elements.key?(name.to_sym)
    end

    # @param [Symbol] key
    #
    # @return [Object]
    def fetch(key)
      raise ::ArgumentError, 'key cannot be nil' if key.nil?

      elements.fetch(key.to_sym) do
        return yield if block_given?

        raise ::KeyError, "#{key} doesn't exist in #{self.class.name} registry"
      end
    end
    alias [] fetch

    private

      # @param [Symbol] method_name
      #
      # @return [true] if key exist
      def respond_to_missing?(method_name, include_private = false)
        elements.key?(method_name) || super
      end

      # @param [Symbol] method_name
      #
      # @return [true] if key exist
      def method_missing(method_name, *)
        elements.fetch(method_name) { super }
      end

  end

end
