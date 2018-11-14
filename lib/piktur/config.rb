# frozen_string_literal: true

module Piktur

  # Provides thread safe configuration.
  #
  # Store configuration for namespaces under `/config/piktur/*.rb`.
  class Config

    extend ::Piktur::Configurable

    # Map noun forms to {Inflector} methods
    #
    # @return [Hash{Symbol=>Symbol}]
    FORMS = { singular: :singularize, plural: :pluralize }.freeze

    # @!attribute [rw] nouns
    #   @return [Symbol] the form in which {.component_types} will be referenced
    setting :nouns, :plural, reader: true, &Types['symbol']
      .constructor { |input| FORMS[input] || FORMS[:plural] }
      .meta(reader: true)
      .default(:plural)
      .method(:call)

    default = 'app/concepts'
    # @!attribute [rw] components_dir
    #   @return [Pathname] the relative path
    setting :components_dir, 'app/concepts', reader: true, &Types.Constructor(Pathname)
      .meta(reader: true)
      .default { |type| type[default] }
      .method(:call)

    # @!attribute [rw] component_types
    #   @return [Array<Symbol>] a list of component types
    setting :component_types, EMPTY_ARRAY, reader: true, &Types['array']
      .constructor { |input| input.map { |e| ::Inflector.send(config.nouns, e).to_sym } }
      .meta(reader: true)
      .default { |type| type[EMPTY_ARRAY] }
      .method(:call)

    # @!attribute [rw] loader
    #   @see Piktur::Loader::Config
    #   @return [Dry::Configurable]
    setting :loader, reader: true do
      default = :active_support
      # @!attribute [rw] use_loader
      #   @return [Boolean]
      # setting(:use_loader, true, reader: true)
      setting :instance, default, reader: true, &Types.Constructor(Loader) { |strategy|
        strategy.is_a?(::Symbol) ? Loader.build(strategy) : strategy
      }
        .meta(reader: true)
        .default { |type| type[default] }
        .method(:call)

      default = ::ENV['DEBUG'].present?
      # @!attribute [rw] debug
      #   @return [Boolean]
      setting :debug, default, reader: true, &Types['params.bool']
        .meta(reader: true)
        .default(default)
        .method(:call)
    end

  end

end

require_relative './config/delegates.rb'
