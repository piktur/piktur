# frozen_string_literal: true

require 'pathname'
require 'active_support/dependencies'
require 'active_support/dependencies/autoload'

# Basic utilities for Piktur applications.
# @todo [define path helpers for each module](https://bitbucket.org/snippets/piktur/M7A6E)
# @todo https://trello.com/c/gcytwRuV/79-decouple-core-dependencies
#
# ## Development directory structure
#
# Run `bin/piktur setup` to prepare development directory
#
# ```
#   |-- /gem_server        # Private gem server
#   |-- /gems              # Store forked gems
#   |-- <project_name>     # Store common config and untracked files ie. `.env`
#     |-- /piktur          # Piktur
#     |-- /piktur_admin    # Piktur::Admin
#     |-- /piktur_api      # Piktur::Api
#     |-- /piktur_blog     #
#     |-- /piktur_client   # Piktur::Client
#     |-- /piktur_core     # Piktur::Core
#     |-- /piktur_docs     # Piktur::Docs
# ```
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

  # Returns absolute path to root directory
  # @return [Pathname]
  def self.root
    Pathname.new File.expand_path('../', __dir__)
  end

  # Returns absolute path to local development directory
  # @return [Pathname]
  def self.dev_path
    root.parent
  end

  require_relative './piktur/env.rb'
  require_relative './piktur/support.rb'

  extend ActiveSupport::Autoload

  # Eager load common lib code
  eager_autoload do
    autoload :Support
    autoload :Security
  end

end
