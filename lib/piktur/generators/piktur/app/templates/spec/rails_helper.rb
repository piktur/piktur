# Ensure RAILS_ENV set before loading Rails environment
ENV['RAILS_ENV'] = 'test'

# @note In order to accurately assess coverage `SimpleCov.start` **must** be called **before
#   application loaded**
#
#   @see https://github.com/colszowka/simplecov/issues/16#issuecomment-113091244 simplecov#16
#
#   `Rails.application.eager_load! if ENV['COVERAGE']`
#
if ENV['COVERAGE']
  require 'simplecov'

  # Save results to CI artifacts directory
  # @see https://circleci.com/docs/code-coverage/#adding-and-configuring-a-coverage-library
  if ENV['CIRCLECI'] && ENV['CIRCLE_ARTIFACTS']
    dir = File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')
    SimpleCov.coverage_dir(dir)
  end

  SimpleCov.start 'rails'
end

require_relative '../config/environment'
require 'piktur/spec/rails_helper'
require_relative './support/test_helpers'

RSpec.configure do |c|
  # c.support_dirs[<:app_name>] = Rails.root.join('spec/support')
  # c.support_files = :piktur_core # <:app_name>
  # c.extend  Piktur::Spec::Helpers::Controllers, type: :controller
  # c.extend  Piktur::Spec::Helpers::Requests,    type: :request
  # c.extend  Piktur::Spec::Helpers::Routing,     type: :routing
  # c.extend  Piktur::Spec::Helpers::Serializers, type: :serializer
  # c.extend  Piktur::Spec::Helpers::Model,       type: :serializer
  # c.extend  Piktur::Spec::Helpers::Model,       type: :model
  # c.include Piktur::Spec::Helpers::Features,    type: :feature
end
