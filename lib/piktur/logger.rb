# frozen_string_literal: true

require 'logger'

Piktur::LOGGER ||= ::Logger.new($stdout, level: Piktur.env.test? ? :error : :debug)

# @return [Logger]
if defined?(::Rails) && ::Rails.logger
  def Piktur.logger; ::Rails.logger; end
else
  def Piktur.logger; self::LOGGER; end
end
