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
        @files    = Services::FileIndex.new(loaded)
        @paths    = loaded(attr: :path)
        @railties = loaded(predicate: :engine?, attr: :railtie)
        @servers  = Services::Servers.new(applications)
        freeze
      end

      # @return [Array<Services::Service>]
      def all
        return @all if defined?(@all)
        @all = []
        count = 0
        %w(libraries engines applications).each do |e|
          klass    = Services.const_get(e.classify, false)
          services = Services.send(e).map { |name, **data| klass.new(name, count += 1, data) }
          @all.concat(services)
          self.class.send(:define_method, e) { services }
        end
        @all.freeze
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

      # @param [Symbol] predicate
      # @param [Symbol] attr
      # @return [Array<Services::Service>]
      def loaded(predicate: nil, attr: nil)
        loaded = select(&:loaded?)
        loaded.select!(&predicate) if predicate
        loaded.map!(&attr) if attr
        loaded
      end

      # @see Rails::Railtie::Configuration.eager_load_namespaces
      # @return [Array<Module, Class>]
      def eager_load_namespaces
        loaded(attr: :eager_load).flatten
      end

      # Returns Service object for current application
      # @return [Services::Service]
      def application
        self[Pathname.pwd.basename] # Rails.root.basename if defined?(Rails)
      end

      # @return [Boolean]
      def require
        @dependencies.each { |e| require e.name }
      end

    end

  end

end
