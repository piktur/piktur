# frozen_string_literal: true

module Piktur

  # Utility modules
  #
  # @example
  #   Support.install(:json, :types, inflection: { option: true })
  module Support

    extend ::ActiveSupport::Autoload

    autoload :Cache
    autoload :Calc
    autoload :Container
    autoload :Enum
    autoload :Format
    autoload :Inheritable
    autoload_under 'piktur/support/inheritable' do
      autoload :Ext
    end
    autoload :Inflector
    autoload :Pathname
    autoload :Hash
    autoload :Introspection
    autoload :JSON, 'piktur/support/json'
    autoload :Object
    autoload_under 'piktur/support/hash' do
      autoload :WithAttrReader
    end
    autoload :SerializableURI, 'piktur/support/uri'
    autoload :Types
    autoload :URI, 'piktur/support/uri'

  end

end

require_relative './constants.rb'
require_relative './support/extensions.rb'
require_relative './support/container.rb'
