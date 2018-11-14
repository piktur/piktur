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

  # Set a conditional debugger entry point.
  # The debugger is triggered in debug mode only.
  #
  # @example Raise Exception after degugger session closed.
  #   begin
  #     do(something)
  #   rescue CriticalError => err
  #     ::NAMESPACE.debug(binding, true, error: err)
  #   end
  #
  # @example Log warning before debugger session opened.
  #   begin
  #     do(something)
  #   rescue TrivialError => err
  #     ::NAMESPACE.debug(binding, true, warning: err)
  #   end
  module Debugger

    # @param [Object] obj The Object to debug, typically a `Binding`.
    # @param [Object] diff
    # @param [Hash] options
    #
    # @option [String] options :warning
    # @option [String] options :error
    # @option [Symbol] options :throw
    # @option [Exception] options :raise
    #
    # @see DEBUGGER
    #
    # @return [void]
    def debug(obj = binding, diff = true, warning: nil, error: nil, **options) # rubocop:disable MethodLength
      const_get(:DEBUGGER)[obj, diff] unless env.production?

      if options[:raise]
        self::Errors.raise(options[:raise])
      elsif options[:throw]
        self::Errors.throw(options[:throw])
      elsif error
        self::Errors.error(error)
      elsif warning
        self::Errors.warn(warning)
      end

      nil
    end

  end

end
