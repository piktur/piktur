# frozen_string_literal: true

module Piktur

  module Services

    # @example
    #   Index.new 'piktur_security', 'piktur_store', component_types: [:model]
    class Index

      # @!method search
      #   @see Services::FileIndex#search
      #   @return [Array<String>]
      delegate :search, to: :files

      # @param [String] services Gem name per service dependency
      # @param [Hash] options
      #
      # @option options [Array<Symbol>] :component_types (nil) A list of expected component types
      def initialize(*services, component_types: nil)
        # @note Rails::Engline::Configuration#railties_order determined accordingly
        # (engines + applications).map(&:railtie).compact
        self.dependencies = services
        self.files        = component_types
        %i(paths application railties servers eager_load_namespaces to_prepare).each { |m| send(m) }
        (railties << application.railtie).freeze
        freeze
      end

      # @return [Array<Services::Service>]
      def all
        return @all if defined?(@all)
        n = -1
        @all = %w(libraries engines applications).each.with_object([]) do |e, a|
          klass    = Services.const_get(e.camelize.singularize, false)
          services = Services.send(e).map { |s, opts| klass.new(s, position: n += 1, **opts) }
          self.class.send(:define_method, e) { services }
          a.concat(services)
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

      # @!attribute [r] dependencies
      #   @return [Array<Service>] A list of all required {Piktur} services
      attr_reader :dependencies

      # @param [Array<String>] services
      #
      # @return [void]
      def dependencies=(services)
        @dependencies = all.select { |e| e if e.name.in?(services) }
      end

      # @!attribute [r] application
      #   @return [Application] A {Service} object for the loaded application
      def application
        @application ||= loaded.find { |e| e.application? && e.railtie }
      end

      # @!attribute [r] files
      #   @return [Services::FileIndex]
      attr_reader :files

      # @param [Array<Symbol>]
      #
      # @return [void]
      def files=(component_types)
        @files = FileIndex.new(loaded, component_types: component_types)
      end

      # @!attribute [r] paths
      #   @return [Set<Pathname>] An immutable list of root paths for all loaded services
      def paths
        @paths ||= loaded { |arr| arr.map(&:path) }.to_set.freeze
      end

      # @!attribute [r] railties
      #   @return [Array<Class>] A list of all loaded `Rails::Railtie`s
      def railties
        @railties ||= loaded { |arr| arr.select(&:engine?).map(&:railtie) }.to_set
      end

      # @!attribute [r] servers
      #   @return [Services::Servers]
      def servers
        @servers ||= Services::Servers.new(applications)
      end

      # @!attribute [r] to_prepare
      #   @see Rails::Railtie::Configuration.eager_load_namespaces
      #   @return [Set<Module, Class>]
      def eager_load_namespaces
        @eager_load_namespaces ||= Set.new loaded { |enum| enum.flat_map(&:eager_load) }
      end

      # @!attribute [r] to_prepare
      #   Returns an Array of Modules to be initialized on boot
      #   @see https://bitbucket.org/piktur/piktur_core/src/master/lib/piktur/setup/boot.rb
      #   @return [Array]
      def to_prepare
        return @to_prepare if defined?(@to_prepare)
        @to_prepare = Set[::Piktur]
        @to_prepare << application.namespace if application.namespace.respond_to?(:to_prepare)
        @to_prepare
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

      # @return [Boolean]
      def require
        dependencies.each { |e| require e.name }
      end

      # @return [String]
      def inspect
        "<#{self.class.name} services=#{loaded.map(&:name)}>"
      end

    end

  end

end
