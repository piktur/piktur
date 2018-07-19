# frozen_string_literal: true

module Piktur

  module Services

    # @example
    #   Index.new 'piktur_security', 'piktur_stores'
    class Index

      # @!attribute [r] dependencies
      #   @return [Array<Service>] A list of all required {Piktur} services
      attr_reader :dependencies

      # @!attribute [r] file_index
      #   @return [Services::FileIndex]
      attr_reader :file_index

      # @param [String] services Gem name per service dependency
      # @param [Hash] options
      #
      # @option options [Array<String>] :component_types (nil) A list of expected component types
      def initialize(services, options = EMPTY_HASH)
        # @note Rails::Engline::Configuration#railties_order determined accordingly
        # (engines + applications).map(&:railtie).compact!
        self.dependencies = services

        %i(paths application railties servers eager_load_namespaces)
          .each { |m| send(m) } # memoize attributes

        (railties << application.railtie).freeze if application

        @file_index = FileIndex.new(loaded)

        freeze
      end

      # @return [Array<Services::Service>]
      def all
        return @all if defined?(@all)
        n = -1
        @all = %w(libraries engines applications).each.with_object([]) do |e, a|
          klass    = Services.const_get(Support::Inflector.classify(e), false)
          services = Services.send(e).map { |s, opts| klass.new(s, position: n += 1, **opts) }
          self.class.send(:define_method, e) { services }
          a.concat(services)
        end.freeze
      end
      alias to_a all

      # @param [Proc] block
      #
      # @yieldparam [Services::Service] service
      #
      # @return [Enumerator]
      def each(&block); all.each(&block); end

      # @!method find(&block)
      # @!method map(&block)
      # @!method select(&block)
      # @param see (#each)
      # @return [Enumerator]
      delegate :find, :map, :select, to: :all

      # @example
      #   services = Services::Index.new
      #   services['piktur_api'] # => Services::Service
      #   services[:piktur_api]  # => Services::Service
      #
      # @param [String] name
      #
      # @return [Services::Service]
      def [](name)
        find { |service| service.name == name.to_s }
      end

      # @param [Array<String>] services
      #
      # @return [void]
      def dependencies=(services)
        @dependencies = all.select { |e| services.member?(e.name) }
      end

      # @!attribute [r] application
      #   @return [Service] A {Service} object for the loaded application
      def application
        return @application if defined?(@application)

        @application = loaded.find { |e| e.application? && e.railtie }
        # || self['piktur_spec'].loaded? && self['piktur_spec'].namespace
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

      # Load all dependencies
      # @return [void]
      def require
        dependencies.each { |e| require e.name }
      end

      # @!attribute [r] to_prepare
      #   @see Rails::Railtie::Configuration.eager_load_namespaces
      #   @return [Set<Module, Class>]
      def eager_load_namespaces
        @eager_load_namespaces ||= Set[loaded { |arr| arr.flat_map(&:eager_load) }]
      end

      # @see https://bitbucket.org/piktur/piktur_core/src/master/lib/piktur/setup/boot.rb
      #
      # @return [true] unless :abort is thrown
      def run_callbacks
        error = catch(:abort) do
          dependencies.each do |service|
            next unless service.namespace.respond_to?(__callee__, true)
            service.namespace.send(__callee__)
          end

          application.namespace.send(__callee__) if application &&
              application.namespace.respond_to?(__callee__, true)

          return true
        end

        ::Piktur.debug(binding, warn: "[FAILURE] #{error || __method__} #{__FILE__}:#{__LINE__}")
      end

      %i(
        boot!
        to_prepare
        before_class_unload
        after_class_unload
        to_run
        to_complete
      ).each { |phase| alias_method(phase, :run_callbacks) }
      private :run_callbacks

      # @return [String]
      def inspect
        "#<#{self.class.name} loaded=#{loaded.map(&:name)}>"
      end

      # @return [void]
      def pretty_print(pp); pp.text inspect; end

    end

  end

end
