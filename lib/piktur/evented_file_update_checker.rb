# frozen_string_literal: true

require 'active_support/evented_file_update_checker'

module Piktur

  # @note Ruby cannot share threads between processes. Forking will render the listener useless.
  #   Be sure to boot the listener after forking, ie. when using Spring in development.
  #
  # @see https://github.com/guard/listen/issues/398#issuecomment-223957952
  #
  # EventedFileUpdateChecker passes relevant changes to the `@block` called in {#execute} allowing
  # the the user to make informed decisions about what to load on update.
  class EventedFileUpdateChecker < ::ActiveSupport::EventedFileUpdateChecker

    # Pass `@changes` to the `@block` and clear after execution.
    # @return [void]
    def execute
      @updated.make_false
      @block.call(@changes)
      @changes.clear

      true
    end

    private

      def boot!
        @listener = ::Listen.to(*@dtw, &method(:changed))
        @listener.start
      end

      # @param [Array<String>] modified
      # @param [Array<String>] added
      # @param [Array<String>] removed
      # @return [void]
      def changed(*args)
        @changes ||= []

        args.each.with_index do |event, i|
          filtered = filter(event)
          (@changes[i] ||= Set.new).merge(filtered) if filtered
        end

        @updated.make_true if @changes.any?(&:present?)
      end

      # Remove irrelevant changes
      # @return [Array<String>, nil]
      def filter(changes)
        changes.keep_if { |f| watching?(f) }.presence
      end

  end

end
