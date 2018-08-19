# frozen_string_literal: true

module Piktur

  # ActiveSupport::StringInquirer utilises method_missing and is fairly slow. Given {#env} is used
  # rather heavily throughout the code base, a ~200% performance increase over `Rails.env` is
  # welcome.
  #
  # @example
  #   class R
  #     class << self
  #       def env; @_env; end
  #     end
  #
  #     instance_variable_set :@_env, ActiveSupport::StringInquirer.new(if defined?(::Rails)
  #       ENV.fetch('RAILS_ENV') { ENV.fetch('RACK_ENV') { DEVELOPMENT } }
  #     else
  #       ENV.fetch('ENV') { DEVELOPMENT }
  #     end)
  #   end
  #
  #   require 'benchmark/ips'
  #   Benchmark.ips do |x|
  #     x.report('Piktur::Environment') do
  #       Environment.instance.test?
  #       Environment.instance.development?
  #     end
  #     x.report('Rails.env') do
  #       R.env.test?
  #       R.env.development?
  #     end
  #     x.compare!
  #   end
  class Environment < ::String

    require 'singleton'
    include ::Singleton

    DEVELOPMENT = 'development'
    PRODUCTION  = 'production'
    STAGING     = 'staging'
    TESTING     = 'test'

    # rubocop:disable BlockDelimiters
    def initialize(*)
      super ::ENV.fetch('RAILS_ENV') {
        ::ENV.fetch('RACK_ENV') {
          ::ENV.fetch('ENV') {
            DEVELOPMENT
          }
        }
      }
      freeze
    end

    def development?; self == DEVELOPMENT; end

    def production?; self == PRODUCTION; end

    def staging?; self == STAGING; end

    def testing?; self == TESTING; end

    private

      def method_missing(method_name, *)
        method_name.match?(/\?/) ? false : super
      end

      def respond_to_missing?(method_name, *)
        method_name.match?(/\?/) || super
      end

  end

end
