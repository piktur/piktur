# frozen_string_literal: true

require 'rails/generators'
require_relative './generators/base'
require_relative './generators/piktur/app/app_generator'
require_relative './generators/piktur/config/config_generator'

module Piktur

  module Generators # rubocop:disable Documentation

    include Rails::Generators

  end

end
