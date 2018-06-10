# frozen_string_literal: true

require 'active_support/logger'
require 'active_support/tagged_logging'

Piktur::LOGGER ||= ActiveSupport::TaggedLogging.new(
  ActiveSupport::Logger.new(
    $stdout,
    formatter: ActiveSupport::Logger::SimpleFormatter.new,
    level:     Piktur.env.test? ? :error : :debug
  )
)

# @return [Logger]
def Piktur.logger; self::LOGGER; end
