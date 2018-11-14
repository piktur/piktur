# frozen_string_literal: true

module Piktur::Container # rubocop:disable ClassAndModuleChildren

  # Adds:
  #   * Key coercion capabilities to `Dry::Container::Mixin#register`
  #   * Reader for namespace_separator
  module Key

    # @return [String]
    def self.format(input, namespace_separator = '.')
      ::Inflector.underscore(input.to_s).tr("/\s", namespace_separator).tap(&:downcase!)
    end

    # @return [String]
    def namespace_separator; config.namespace_separator; end

    # @return [String] The normalized key input
    def to_key(input)
      if input.is_a?(::Array)
        input.map { |e| to_key(e) }.join(namespace_separator)
      else
        Key.format(input, namespace_separator)
      end
    end

  end

end
