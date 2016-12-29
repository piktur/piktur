# frozen_string_literal: true

require 'pathname'
require 'active_support/dependencies'
require 'active_support/dependencies/autoload'

require_relative './piktur/env.rb'

# Basic utilities for Piktur applications.
# @todo [define path helpers for each module](https://bitbucket.org/snippets/piktur/M7A6E)
# @todo https://trello.com/c/gcytwRuV/79-decouple-core-dependencies
#
# ## Constant loading
#
# `piktur_core` must remain portable. Be clear about the relevance and broader utility of a
# constant.
#
#   * Avoid introducing **irrelevant dependencies**
#   * Maintain **separation of concerns**
#
module Piktur

  extend ActiveSupport::Autoload

  # Eager load common lib code
  eager_autoload do
    autoload :Support
    # autoload :Settings
    # autoload :Coders
    autoload :Security
  end

  # Returns absolute path to root directory
  # @return [Pathname]
  def self.root
    Pathname.new File.expand_path('../', __dir__)
  end

end
