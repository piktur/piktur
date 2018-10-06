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

      # @!attribute [r] applications
      #   @return [Array<Application>]
      attr_reader :applications

      # @!attribute [r] engines
      #   @return [Array<Engine>]
      attr_reader :engines

      # @!attribute [r] libraries
      #   @return [Array<Library>]
      attr_reader :libraries

      # @param [String] services Gem name per service dependency
      # @param [Hash] options
      #
      # @option options [Array<String>] :component_types (nil) A list of expected component types
      def initialize(*)
        Services.define

        # @note Sequencing WILL BE determined by order as listed within Gemfile.
        #   Ensure correct Rails::Engine::Configuration#railties_order
        self.dependencies = Services.dependencies.map(&:name)

        %i(paths application railties servers eager_load_namespaces)
          .each { |m| send(m) } # memoize attributes

        (railties << application.railtie).freeze if application

        @file_index = FileIndex.new(loaded)

        freeze
      end

      # @return [Array<Services::Service>]
      def all # rubocop:disable MethodLength
        return @all if defined?(@all)

        n = -1

        @all = %w(libraries engines applications).each.with_object([]) do |type, arr|
          klass = Support::Inflector.constantize(type, Services, classify: true, traverse: false)
          services = Services.send(type).map do |service, options|
            klass.new(service, position: n += 1, **options)
          end

          instance_variable_set("@#{type}".to_sym, services)
          arr.concat(services)
        end

        @all.freeze
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
        @dependencies = all.select { |service| services.member?(service.name) && !service.itself? }
      end

      # @!attribute [r] application
      #   @return [Service] A {Service} object for the loaded application
      def application
        @application ||= loaded.find { |e| e.application? && e.railtie }
      end

      # @!attribute [r] paths
      #   @return [Set<Pathname>] An immutable list of root paths for all loaded services
      def paths
        @paths ||= loaded { |arr| arr.map(&:path) }.to_set.freeze
      end

      # @!attribute [r] railties
      #   @return [Array<Rails::Railtie>] A list of all loaded `Rails::Railtie`s
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
      alias gems names

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
        @eager_load_namespaces ||= Set[*loaded { |arr| arr.flat_map(&:eager_load) }]
      end

      # @param [Array<Module>] exclude
      #
      # @see https://bitbucket.org/piktur/piktur_core/src/master/lib/piktur/setup/boot.rb
      #
      # @return [true] unless :abort is thrown
      def run_callbacks(*exclude)
        error = catch(:abort) do
          dependencies.each do |service|
            next if exclude.include?(namespace = service.namespace)
            next unless namespace.respond_to?(__callee__, true)

            namespace.send(__callee__)
          end

          # Developers SHOULD run callbacks at their discretion. The call SHOULD
          # `run_callbacks` for the application's dependencies.
          #
          # application.namespace.send(__callee__) if application &&
          #     application.namespace.respond_to?(__callee__, true)

          return true
        end

        ::NAMESPACE.debug(binding, warn: "[FAILURE] #{error || __method__} #{__FILE__}:#{__LINE__}")
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
