# frozen_string_literal: true

begin
  require 'pry'
rescue LoadError => err
  nil # Gem not available
end

module Piktur # rubocop:disable Documentation

  DEBUGGER = ->(object, diff) { object.pry if ENV['DEBUG'] && diff.present? }
  # ->(*) { Piktur.logger.error } if Piktur.env.production?
  private_constant :DEBUGGER

end
