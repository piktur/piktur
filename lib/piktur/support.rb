# frozen_string_literal: true

require 'piktur/support/require_dependencies'

module Piktur

  # Utility methods
  module Support

    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Autoload
      autoload :Uri
      autoload :Cloneable if defined?(Rails) && Rails.env.test?
    end

  end

end
