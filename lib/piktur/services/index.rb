# frozen_string_literal: true

module Piktur

  module Services

    # @example
    #   Index.new 'piktur_security', 'piktur_store'
    class Index

      # @!attribute [r] dependencies
      #   @return [Array<Services::Service>]
      attr_reader :dependencies

      # @!attribute [r] railties
      #   Return loaded `Rails::Railtie`s
      #   @return [Array<Class>]
      attr_reader :railties

      # Returns Service object for current application
      # @return [Services::Application]
      attr_reader :application

      # @!attribute [r] paths
      #   Return root directories
      #   @return [Array<Pathname>]
      attr_reader :paths

      # @!attribute [r] files
      #   @return [Services::FileIndex]
      attr_reader :files

      # @!attribute [r] servers
      #   @return [Services::Servers]
      attr_reader :servers

      # @!method search
      #   @see Services::FileIndex#search
      #   @return [Array<String>]
      delegate :search, to: :files

      # @param [String] services Gem name per service dependency
      def initialize(*services)
        @dependencies = all.select { |e| e if e.name.in?(services) }
        # @note Rails::Engline::Configuration#railties_order determined accordingly
        # (engines + applications).map(&:railtie).compact
        @files       = Services::FileIndex.new(loaded)
        @paths       = loaded { |arr| arr.map(&:path) }.to_set.freeze
        @application = loaded.find { |e| e.application? && e.railtie }
        @railties    = loaded { |arr| arr.select(&:engine?).map(&:railtie) }.to_set
        @servers     = Services::Servers.new(applications)
        (@railties << @application.railtie).freeze
      end

      # @return [Array<Services::Service>]
      def all
        return @all if defined?(@all)
        n = -1
        @all = %w(libraries engines applications).each.with_object([]) do |e, a|
          klass    = Services.const_get(e.camelize.singularize, false)
          services = Services.send(e).map { |e, opts| klass.new(e, position: n += 1, **opts) }
          self.class.send(:define_method, e) { services }
          a.concat services
        end.freeze
      end
      alias to_a all
      delegate :each, :find, :map, :select, to: :all

      # @example
      #   services = Services::Index.new
      #   services['piktur_api'] # => Services::Service
      #   services['api']        # => Services::Service
      #   services[:api]         # => Services::Service
      #
      # @return [Services::Service]
      def [](name)
        # `String#end_with?` 14x faster than `=~` when `name` is a Symbol
        # @see file:spec/benchmark/string_manipulation.rb SymbolConversionRegexpPerformance
        find { |service| service.name.end_with?(name.to_s) }
      end

      # @return [Array<String>]
      def names
        map(&:name)
      end

      # @overload loaded(predicate: :method?)
      #   Select loaded Services where `predicate` true
      # @overload loaded(attr: :method)
      #   Collect `attr` for each loaded Service
      #   @return [Array<Object>]
      # @overload loaded(predicate: :method?, attr: :method)

      # @yieldparam [Array<Services::Service>] arr
      # @return [Array<Services::Service>]
      def loaded
        if block_given?
          yield select(&:loaded?)
        else
          select(&:loaded?)
        end
      end

      # @see Rails::Railtie::Configuration.eager_load_namespaces
      # @return [Set<Module, Class>]
      def eager_load_namespaces
        @_eager_load_namespaces ||= Set.new loaded { |enum| enum.flat_map(&:eager_load) }
      end

      # Return an Array of Modules for which setup hooks should be called on boot
      # @return [Array]
      def to_prepare
        return @_to_prepare if defined?(@_to_prepare)
        @_to_prepare ||= Set[::Piktur]
        @_to_prepare << application.namespace if application.namespace.respond_to?(:setup)
        @_to_prepare
      end

      # @return [Boolean]
      def require
        @dependencies.each { |e| require e.name }
      end

    end

  end

end
