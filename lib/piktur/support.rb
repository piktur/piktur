# frozen_string_literal: true

module Piktur

  # Utility modules
  module Support

    extend ActiveSupport::Autoload

    autoload :Dependencies
    autoload :Inheritable
    autoload :Enum
    autoload :Hash
    autoload :SerializableURI, 'piktur/support/uri'
    autoload :URI,             'piktur/support/uri'
    autoload :JSON,            'piktur/support/json'

  end

end
