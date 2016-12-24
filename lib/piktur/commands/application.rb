# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require_relative '../generators'

Piktur::Generators::AppGenerator.class_eval do
  # We want to exit on failure to be kind to other libraries. This is only when accessing via
  # CLI
  # @return [Boolean]
  def self.exit_on_failure?
    true
  end
end

args = Rails::Generators::ARGVScrubber.new(ARGV).prepare!
Piktur::Generators::AppGenerator.start args
