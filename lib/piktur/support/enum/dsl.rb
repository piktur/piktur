# frozen_string_literal: true

module Piktur::Support # rubocop:disable ClassAndModuleChildren

  class Enum

    # :nodoc
    DSL = Struct.new(:values, :options) do
      def self.call(namespace, options, &block)
        options[:i18n_scope] ||= namespace

        dsl = new({}, options).tap do |dsl| # rubocop:disable ShadowingOuterLocalVariable
          dsl.i18n_scope(namespace) if dsl.respond_to?(:i18n_scope)
          dsl.instance_exec(&block)
        end

        args = [dsl.options.delete(:block)]
        args.unshift({ values: dsl.values }.update(dsl.options))
      end

      # Register an attribute for which the {Predicates} module should be built.
      #
      # @param [Symbol, String] attribute The attribute containing the enumerated value
      #
      # @return [void]
      def predicates(attribute)
        options[:predicates] = attribute
      end

      # Register an attribute for which the {Attributes} module should be built.
      #
      # @param [Symbol, String] attribute The attribute containing the enumerated value
      #
      # @return [void]
      def attributes(attribute)
        options[:attributes] = attribute
      end

      # Register the attribute to build scopes module for.
      #
      # @param [Symbol, String] attribute
      #
      # @return [void]
      def scopes(attribute)
        options[:scopes] = attribute
      end

      # @param [Symbol, String, Module] Use a scope other than the parent module name.
      #
      # @return [void]
      def i18n_scope(value)
        return if value == ::Object

        options[:i18n_scope] = case value
        when ::Module
          if value.respond_to?(:Name) then value.Name.i18n_key
          else Enum.inflector.underscore(value.to_s).to_sym
          end
        when ::String then value.to_sym
        when ::Symbol then value
        end
      end

      # Record intention to register Enum with the application container
      #
      # @return [void]
      def register
        options[:register] = true
      end

      # Block to extend the Enum instance.
      #
      # @yieldparam [Enum]
      #
      # @return [void]
      def finalize(&block)
        options[:block] = block
      end

      # @param [Symbol] key
      # @param [Hash] options
      #
      # @return [void]
      def default(key, **options)
        options[:default] = true
        values[key] = options
      end

      # @param [Symbol] key
      # @param [Hash] options
      #
      # @return [void]
      def value(key, **options)
        values[key] = options
      end
    end

  end

end
