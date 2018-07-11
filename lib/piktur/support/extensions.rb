# frozen_string_literal: true

module Piktur

  # :nodoc
  module Support

    # List available extensions for core Ruby types
    # @return [Hash]
    EXTENSIONS = {
      hash:      [:Hash],
      inflector: [:Inflector],
      json:      [:JSON],
      module:    [:Introspection],
      object:    [:Object],
      types:     [:Types]
    }.freeze
    private_constant :EXTENSIONS

    # Load and/or install extensions and define constant aliases.
    #
    # @example
    #   Support.install(:json, :types, inflection: { option: true })
    #
    # @param [Array<Symbol>] ext A list of non-configurable extension(s)
    # @param [Hash] configurable A hash of configurable extension(s)
    #
    # @return [void]
    def self.install(*ext, **configurable) # rubocop:disable AbcSize, MethodLength
      fn = lambda { |name, **options|
        EXTENSIONS[name].each do |const|
          mod = const_get(const, false)
          mod.send(:install, options) if mod.respond_to?(:install, true)
        end
      }
      ext.each(&fn)

      return if configurable.blank?

      configurable.delete(:helpers)&.each do |group|
        ::Object.const_set(
          const = Inflector.camelize(group),
          Inflector.constantize(const, Support, camelize: true)
        )
      end

      configurable.each { |e| fn[*e] }
    end

  end

end
