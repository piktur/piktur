# frozen_string_literal: true

module Piktur

  module Support

    module Types # rubocop:disable Documentation

      # :nodoc
      class Container

        include ::Dry::Container::Mixin
        include Support::Container::Mixin

        def self.new(*)
          super.tap do |container|
            container.merge(::Dry::Types.container)
          end
        end

        # @return [void]
        def finalize!
          freeze if ::NAMESPACE.env.production?
        end

      end

      extend Support::Container::Delegates

      # @!attribute [rw] container
      #   @return [Dry::Container{String => Object}]
      def self.container; @container ||= Container.new; end

    end

  end

end
