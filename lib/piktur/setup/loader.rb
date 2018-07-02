# frozen_string_literal: true

module Piktur

  # Provides an interface to filter, sort and/or load a {Filters#target} directory's contents.
  #
  # @note Application components **SHOULD** be defined within their own file. DO NOT use
  #   `./<components_dir>/<namespace>/setup.rb` to define multiple constants.
  #
  # @example Configure the a loader for the application
  #   Piktur::Config.configure do |config|
  #     config.nouns            = :plural
  #     config.components_dir   = 'app/concepts'
  #     config.component_types  = %w(models transactions)
  #     (config.loader.instance = :active_support).tap do |loader|
  #       loader.target = config.components_dir
  #       loader.types  = config.component_types
  #     end
  #   end
  #
  # @example Add the loader interface to a module
  #   Piktur.extend Piktur::Loader::Ext
  #   Piktur.loader # => <Loader[ActiveSupport] booted=true entries=100>
  #   Piktur.files(type: :models) # => ['model.rb', 'namespace/model.rb']
  #
  # @example Load a subset
  #   Piktur.load(paths: 'users')
  #   Piktur.load(namespaces: %w(users accounts))
  #   Piktur.load(type: :models)
  #
  # @example Load all namespaces listed in {Piktur.namespaces}
  #   Piktur.load
  #
  # @example Sort files
  #   Piktur.loader.sort(:models) # => ['a/model.rb', 'a/models/variant.rb', 'z/model.rb']
  #   Piktur.loader.sort('a', 'x', '*.js') # => ['a/x.js', 'a/a.js', 'a/b.js']
  #
  # @example Apply the sorting algorithm to an arbitrary file list
  #   Piktur::Loader::Sorter.call(%w(path/z, path/a)) # => ['path/a', 'path/z']
  #
  # @example Retrieve a list of files -- the files will not be loaded
  #   models = files(type: :models) # => ['model_a.rb', 'model_b.rb']
  #     .map { |path| root, target, path = rpartition(path, target) }
  #     # And with this list, build a JSON representation of the application schema
  #     .map { |path| const = Inflector.classify(path); Inflector.constantize(const) }
  #
  #   Piktur::Schema.call(models).to_json
  #   # => {
  #   #   "user": {
  #   #     "attribute": {
  #   #       "type": "String",
  #   #       "required": true
  #   #     }
  #   #   },
  #   #   "catalogueItems": { ... }
  #   # }
  #
  # @see Piktur::Engine
  # @see https://bitbucket.org/piktur/piktur/wiki/Structure.markdown#Components
  #
  # {include:Loader::ActiveSupport}
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

    class << self

      # Build loader according to given `strategy`
      #
      # @param [Symbol] strategy
      #
      # @return [Piktur::Loader::Base] instance
      def build(strategy)
        raise StandardError, STRATEGY_UNDEFINED_MSG % strategy unless
          STRATEGIES.include?(strategy)

        ::Inflector.constantize(strategy, Loader, camelize: true).new
      end

      # @param see (Base#call)
      # @param see (Filters#files)
      # @param see (Load#load)
      #
      # @return [Array<String>] A list of autoloadable paths
      def call(loader, options = EMPTY_OPTS) # rubocop:disable MethodLength
        options, filter, to_load = prepare_options(options)

        if to_load
          if to_load.is_a?(::Enumerable)
            to_load.flat_map { |e| options[filter] = e; loader.send(__callee__, options) }
          else
            options[filter] = to_load
            loader.send(__callee__, options)
          end
        else # Load all {Piktur.namespaces}
          loader.send(__callee__, options)
        end
      end
      alias files call

      private

        # @param see (.call)
        #
        # @option options [Boolean] :index (false) Apply index only filter
        #
        # @return [Array<(Hash, Symbol, Object)>]
        def prepare_options(paths: nil, type: nil, index: false, **options)
          return [options, :type, type] if type

          options[:pattern] ||= Matcher::Glob::INDEX_PATTERN if index

          paths ? [options, :path, paths] : options
        end

    end

  end

end
