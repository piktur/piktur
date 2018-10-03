# frozen_string_literal: true

require 'active_support/logger'
require 'active_support/tagged_logging'

module Piktur

  # :nodoc
  module Logger

    class << self

      def new # rubocop:disable MethodLength
        ::ActiveSupport::TaggedLogging.new(
          ::ActiveSupport::Logger.new(
            if log_to_stdout?
              $stdout
            else
              f = ::File.open(path, 'a')
              f.binmode
              # To improve performance in production disable auto flush.
              # Write only when buffer full.
              f.sync = !parent.env.production?
              f
            end,
            formatter: ::ActiveSupport::Logger::SimpleFormatter.new,
            level: parent.env.test? ? :error : :debug
          )
        )
      end

      private def path
        return @path if defined?(@path)

        @path = ::File.expand_path("log/#{parent.env}.log", ::Dir.pwd)
        ::FileUtils.mkdir_p(@path) unless ::File.exist?(@path)
        @path
      end

      private def log_to_stdout?
        if defined?(::Rails)
          ::ENV['RAILS_LOG_TO_STDOUT'].present?
        else
          !parent.env.production?
        end
      end

    end

  end

end
