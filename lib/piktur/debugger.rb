# frozen_string_literal: true

require 'pry'

module Piktur # rubocop:disable Documentation

  DEBUGGER = ->(object, diff) { object.pry if ENV['DEBUG'] && diff.present? }
  # ->(*) { nil } NOOP if Piktur.env.production?
  private_constant :DEBUGGER

end
