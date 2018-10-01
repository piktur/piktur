# frozen_string_literal: true

module Piktur

  # Provides thread safe configuration.
  #
  # Store configuration for namespaces under `/config/piktur/*.rb`.
  class Config

    extend ::Piktur::Configurable

    # @!attribute [rw] services
    #   @example
    #     Piktur::Config.configure do |config|
    #       config.services = %w(piktur_library piktur_engine piktur_application)
    #
    #       # With options
    #       config.services = %w(lib).push(component_types: [:models, :serializers])
    #     end
    #
    #   @see Piktur::Services
    #   @return [Services::Index]
    setting :services, EMPTY_ARRAY, reader: true, &Types.Constructor(Services::Index) { |services|
      options = services.pop if services && services[-1].is_a?(::Hash)
      Services::Index.new(services.map(&:to_s), *options)
    }
      .meta(reader: true)
      .default { |type| type[EMPTY_ARRAY] }
      .method(:call)

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

    # @!attribute [rw] components_dir
    #   @return [Pathname] the relative path
    setting :components_dir, 'app/concepts', reader: true, &Types.Constructor(Pathname)
      .meta(reader: true)
      .default { |type| type['app/concepts'] }
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
      # @!attribute [rw] use_loader
      #   @return [Boolean]
      # setting(:use_loader, true, reader: true)
      setting :instance, :active_support, reader: true, &Types.Constructor(Loader) { |strategy|
        strategy.is_a?(::Symbol) ? Loader.build(strategy) : strategy
      }
        .meta(reader: true)
        .default { |type| type[:active_support] }
        .method(:call)

      # @!attribute [rw] debug
      #   @return [Boolean]
      setting :debug, ::ENV['DEBUG'], reader: true, &Types['params.bool']
        .meta(reader: true)
        .default { ::ENV['DEBUG'].present? }
        .method(:call)
    end

  end

end
