# frozen_string_literal: true

# Provides runtime environment predicates
module Piktur::Environment::Predicates # rubocop:disable ClassAndModuleChildren

  # @return [Environment]
  def env; self::Environment.instance; end

  # Predicate checks existence of Rails application singleton. Use when opting out of operations
  # that will be handled by the Rails boot.
  #
  # @return [Boolean]
  def rails?
    defined?(::Rails) && ::Rails.application.present? # &.initialized?
  end

  # @return [Boolean]
  def initialized?
    rails? && ::Rails.application.initialized?
  end

  # @return [Boolean]
  def rake?
    defined?(::Rake) && ::Rake.application.present?
  end

  # The predicate may be used to limit loading when booting the test environment.
  #
  # @see file:bin/env
  #
  # @return [Boolean]
  def rspec?; ::ENV['TEST_RUNNER'].present?; end

  # Predicate checks Rails application singleton is an instance of the dummy application.
  #
  # @return [Boolean]
  def dummy?
    defined?(::Piktur::Spec::Application) &&
      ::Rails.application.is_a?(::Piktur::Spec::Application)
  end

end
