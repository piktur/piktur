# frozen_string_literal: true

module Piktur

  # :nodoc
  module Errors

    module_function

    # @param [String] str
    # @return [void]
    def debug(str); parent.logger.debug(str); end

    # @param [String] str
    # @return [void]
    def warn(str); parent.logger.warn(str); end

    # @param [String, Exception] error
    # @return [void]
    def error(err)
      case err
      when ::String    then parent.logger.error(err)
      when ::Exception then parent.logger.error(err.full_message)
      end
    end

    # @param [Symbol] sym
    # @return [void]
    def throw(sym); ::Kernel.throw(sym); end

    # @param [Exception] exception
    # @return [void]
    def raise(exception); ::Kernel.raise(exception); end

  end

end
