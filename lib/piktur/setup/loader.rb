# frozen_string_literal: true

module Piktur

  # Implements code re/loading for {Piktur.components_dir}.
  #
  # @note Application components must be defined within their own file. DO NOT use
  #   `./<components_dir>/<namespace>/setup.rb` to define multiple constants.
  #
  # @example Configure the loading strategy
  #   Piktur::Config.config.loader.instance = :active_support
  #
  # @example Retreive the loader instance
  #   Piktur.loader # => <Loader[ActiveSupport] booted=true entries=100>
  #
  # @example Load all namespaces listed in {Piktur.namespaces}
  #   Piktur.load!
  #
  # @example Load a subset
  #   Piktur.load!(namespaces: %w(users accounts))
  #
  # @example Sort files
  #   Piktur.loader.sort(:models) # => ['a/model.rb', 'a/models/variant.rb', 'z/model.rb']
  #   Piktur.loader.sort('a', 'x', '*.js') # => ['a/x.js', 'a/a.js', 'a/b.js']
  #
  # @example Apply the sorting algorithm to an arbitrary file list
  #   Piktur::Loader::Sorter.call(%w(path/z, path/a)) # => ['path/a', 'path/z']
  #
  # @see Piktur::Engine
  # @see https://bitbucket.org/piktur/piktur/wiki/Structure.markdown#Components
  #
  # {include:Loader::ActivSupport}
  module Loader

    extend ::ActiveSupport::Autoload

    autoload :Ext,            'piktur/setup/loader/ext'
    autoload :Pathname,       'piktur/setup/loader/pathname'
    autoload :Strategies,     strategies = 'piktur/setup/loader/strategies'
    autoload :ActiveSupport,  "#{strategies}/active_support"
    autoload :Base,           "#{strategies}/base"
    autoload :Dry,            "#{strategies}/dry"
    autoload :Filter,         "#{strategies}/filter"
    autoload :Filters,        "#{strategies}/filter"
    autoload :Load,           "#{strategies}/load"
    autoload :Reload,         "#{strategies}/reload"
    autoload :Store,          "#{strategies}/store"
    autoload :ByPath,         "#{strategies}/filters/by_path"
    autoload :ByType,         "#{strategies}/filters/by_type"
    autoload :Matcher,        "#{strategies}/filters/matcher"
    autoload :Predicates,     "#{strategies}/filters/predicates"
    autoload :Sorter,         "#{strategies}/filters/sorter"

    # @return [Array<Symbol>]
    STRATEGIES = %i(
      active_support
      dry
    ).freeze

    # @return [String]
    STRATEGY_UNDEFINED_MSG = "Strategy %s must be one of #{STRATEGIES.join(', ')}"

    Path = Pathname

    # Initialize Loader for given `strategy`
    #
    # @param [Symbol] strategy
    #
    # @return [Piktur::Loader::Base] instance
    def self.call(strategy)
      raise StandardError, STRATEGY_UNDEFINED_MSG % strategy unless
        STRATEGIES.include?(strategy)

      ::Inflector.constantize(strategy, Loader, camelize: true).new
    end

  end

end
