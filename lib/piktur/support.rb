# frozen_string_literal: true

module Piktur

  # Utility methods
  module Support

    extend ActiveSupport::Autoload

    autoload :Hash
    autoload :SerializableURI, 'piktur/support/uri'
    autoload :URI, 'piktur/support/uri'

  end

end
