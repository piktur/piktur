# frozen_string_literal: true

module Piktur

  # Utility modules
  module Support

    extend ActiveSupport::Autoload

    autoload :Dependencies
    autoload :Inheritable
    autoload :Inflector
    autoload :Enum
    autoload :Hash
    autoload :SerializableURI, 'piktur/support/uri'
    autoload :URI,             'piktur/support/uri'
    autoload :JSON,            'piktur/support/json'
    autoload :Calc
    autoload :Format

    EXTENSIONS = {
      hash:      :Hash,
      inflector: :Inflector,
      json:      :JSON
    }.freeze
    private_constant :EXTENSIONS

    # Load and/or install extensions
    # Setup top-level aliases for convenience
    # @param [Hash] options
    # @return [void]
    def self.install(**options)
      options.delete(:helpers)&.each do |group|
        Object.const_set(const = Inflector.camelize(group), Inflector.constantize(const, Support))
      end

      options.each do |k, v|
        ext = const_get(EXTENSIONS[k], false)
        next unless ext.respond_to?(:install, true)
        ext.send(:install, v)
      end
    end

  end

end
