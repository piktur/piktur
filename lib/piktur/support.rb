# frozen_string_literal: true

module Piktur

  # Utility methods
  module Support

    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :URI
    end

  end

end
