# frozen_string_literal: true

require 'pry'

Piktur::DEBUGGER ||= ->(object, diff) { object.pry if ENV['DEBUG'] && diff.present? }
# ->(*) { nil } NOOP if Piktur.env.production?

# Set a conditional debugger entry point. The debugger is only set if ENV['DEBUG'].present?
# triggered when running specs in debug mode.
#
# @example Raise Exception after degugger session closed.
#   begin
#     do(something)
#   rescue CriticalError => error
#     ::Piktur.debug(binding, true, error: error)
#   end
#
# @example Log warning before debugger session opened.
#   begin
#     do(something)
#   rescue TrivialError => error
#     ::Piktur.debug(binding, true, warning: error)
#   end
#
# @param [Object] object The object to debug, typically a `Binding`.
# @param [Object] diff The condition
# @param [Hash] options
#
# @!option [String] options :warning
# @!option [String] options :error
# @!option [Symbol] options :throw
# @!option [Exception] options :raise
#
# @see Piktur::DEBUGGER
#
# @return [void]
if Piktur.env.production?
  def Piktur.debug(*, warning: nil, error: nil, **)
    ::Piktur::Errors.raise(raise)  if raise
    ::Piktur::Errors.throw(throw)  if throw
    ::Piktur::Errors.error(error)  if error
    ::Piktur::Errors.warn(warning) if warning
  end
else
  def Piktur.debug(object, diff = true, warning: nil, error: nil, throw: nil, raise: nil, **)
    ::Piktur::Errors.warn(warning) if warning
    ::Piktur::Errors.error(error)  if error
    ::Piktur::DEBUGGER[object, diff]
    ::Piktur::Errors.throw(throw)  if throw
    ::Piktur::Errors.raise(raise)  if raise
  end
end

module Piktur

  module Deprecation

    class << self

      # Log deprecation warning
      #
      # @example
      #   Deprecation[__method__, __FILE__, __LINE__]
      #
      # @param [Object] object The deprecated functionality
      # @param [String] path The file path
      # @param [String] line The line number
      #
      # @return [void]
      def call(object, *path)
        ::Piktur.logger.warn <<~MSG
          DEPRECATION WARNING: You are using deprecated behavior which will be removed from the next release. (#{object} at #{path.join(':')})
        MSG
      end
      alias [] call

    end

  end

  # Errors
  module Errors

    module_function

    # @param [String] str
    # @return [void]
    def warn(str); ::Piktur.logger.warn(str); end

    # @param [String] str
    # @return [void]
    def error(str); ::Piktur.logger.error(str); end

    # @param [Symbol] sym
    # @return [void]
    def throw(sym); ::Kernel.throw(sym); end

    # @param [Exception] exception
    # @return [void]
    def raise(exception); ::Kernel.raise(exception); end

  end

end
