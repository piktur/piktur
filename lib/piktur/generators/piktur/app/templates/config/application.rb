# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

<% if include_all_railties? -%>
require 'rails/all'
<% else -%>
require 'rails'
# Load required frameworks
require 'active_model/railtie'
require 'active_job/railtie'
<%= comment_if :skip_active_record %>require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
<%= comment_if :skip_sprockets %>require "sprockets/railtie"
<%= comment_if :skip_test_unit %>require "rails/test_unit/railtie"
<% end -%>

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Piktur

  module <%= app_const_base %>

    # @note Global configuration specified in Piktur::Engine
    class Application < Rails::Application

      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      prepare = lambda do
        # @see https://bitbucket.org/piktur/piktur_api/raw/master/config/application.rb
      end

      Spring.after_fork { FactoryBot.reload } if defined?(Spring) && defined?(FactoryBot)

      config.after_initialize do
        prepare.call

        # @since [3f55fd1](https://bitbucket.org/piktur/piktur_core/commits/3f55fd15a53b86a60566742289ed324d1f205ecf?at=master)
        FactoryBot.find_definitions if defined?(FactoryBot)
      end

      # @!group
      # Run before each request
      ActionDispatch::Callbacks.before(&prepare) unless ::Piktur.env.production?

      # Run after each request
      # ActionDispatch::Callbacks.after {}
      # @!endgroup

    end

  end

end

# Load library code here
# require 'piktur/<%= app_name %>'
