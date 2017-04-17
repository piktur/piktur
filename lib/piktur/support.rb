# frozen_string_literal: true

module Piktur

  # Utility methods
  module Support

    extend ActiveSupport::Autoload

    autoload :SerializableURI, 'piktur/support/uri'
    autoload :URI, 'piktur/support/uri'
    autoload :Hash

  end

end
