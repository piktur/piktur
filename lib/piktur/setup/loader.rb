# frozen_string_literal: true

module Piktur

  # Loader handles code loading and setup for Piktur namespaces on boot and reload.
  #
  # @see Piktur::Engine
  module Loader

    # @return [Array<Symbol>]
    STRATEGIES = %i(
      active_support
      dry
    ).freeze

    # @return [String]
    STRATEGY_UNDEFINED_MSG = "Strategy %s must be one of #{STRATEGIES.join(', ')}"

    extend ::ActiveSupport::Autoload

    %w(
      ext
      class_interface
      strategies
    ).each { |f| require_relative "./loader/#{f}.rb" }

    # autoload :ClassInterface, 'piktur/setup/loader/class_interface'
    # autoload :Ext,            'piktur/setup/loader/ext'
    # autoload :Strategies,     'piktur/setup/loader/strategies'
    # autoload :Reloader,       'piktur/setup/loader/reloader'

    # autoload :Base,           'piktur/setup/loader/strategies/base'
    # autoload :ActiveSupport,  'piktur/setup/loader/strategies/active_support'
    # autoload :Dry,            'piktur/setup/loader/strategies/dry'
    # autoload :Trailblazer,    'piktur/setup/loader/strategies/trailblazer'

    # Initialize Loader for given `strategy`
    #
    # @param [Symbol] strategy
    def self.call
      strategy = Config.loader.strategy

      raise StandardError, STRATEGY_UNDEFINED_MSG % strategy unless
        STRATEGIES.include?(strategy)

      require_relative "./loader/strategies/#{strategy}.rb"
      ::Inflector.constantize(strategy, Loader, camelize: true).new
    end

  end

end
