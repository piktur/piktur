# frozen_string_literal: true

require 'pry'
binding.pry
require 'active_support/dependencies'
require_dependency 'piktur/env.rb'
require_dependency 'piktur/version.rb'
require 'pathname'

# Provides basic utilities to generate/organise Piktur application components.
module Piktur

  # Returns absolute path to root directory
  # @return [Pathname]
  def self.root
    Pathname.new File.expand_path('../', __dir__)
  end

  extend ActiveSupport::Autoload

  # Eager load common lib code
  eager_autoload do
    autoload :Support
    # autoload :Settings
    # autoload :Coders
    autoload :Security
  end

end

require_dependency 'piktur_core/piktur_core.rb' if defined?(Rails)
