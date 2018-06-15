# frozen_string_literal: true

module Piktur

  # Utility modules
  module Support

    extend ::ActiveSupport::Autoload

    autoload :Inheritable
    autoload_under 'piktur/support/inheritable' do
      autoload :Ext
    end
    autoload :Inflector
    autoload :Enum
    autoload :FileMatcher, 'piktur/support/file_matcher'
    autoload :FileSorter,  'piktur/support/file_sorter'
    autoload :Hash
    autoload :Object
    autoload_under 'piktur/support/hash' do
      autoload :WithAttrReader
    end
    autoload :SerializableURI, 'piktur/support/uri'
    autoload :URI,             'piktur/support/uri'
    autoload :JSON,            'piktur/support/json'
    autoload :Calc
    autoload :Format
    autoload :Types

    EXTENSIONS = {
      hash:      :Hash,
      inflector: :Inflector,
      json:      :JSON,
      object:    :Object,
      types:     :Types
    }.freeze
    private_constant :EXTENSIONS

    # Load and/or install extensions and define constant aliases.
    #
    # @example
    #   Support.install(:json, :types, inflection: { option: true })
    #
    # @param [Array<Symbol>] ext
    # @param [Hash] configurable
    #   Extension(s) accepting/expecting options
    # @return [void]
    def self.install(*ext, **configurable)
      fn = lambda { |name, **options|
        mod = const_get(EXTENSIONS[name], false)
        mod.send(:install, options) if mod.respond_to?(:install, true)
      }
      ext.each(&fn)

      return if configurable.blank?

      configurable.delete(:helpers)&.each do |group|
        Object.const_set(const = Inflector.camelize(group), Inflector.constantize(const, Support))
      end

      configurable.each { |e| fn[*e] }
    end

  end

end

require_relative './support/constants.rb'
