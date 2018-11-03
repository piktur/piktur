# frozen_string_literal: true

module Piktur::Support # rubocop:disable ClassAndModuleChildren

  module Enum

    module Plugins

      # :nodoc
      module Types

        def self.included(base)
          base.include InstanceMethods
          container.extend Constructor
        end

        # @return [Object] The types container
        def self.container
          Enum.config.types.is_a?(Proc) ? Enum.config.types.call : Enum.config.types
        end

        # :nodoc
        module Constructor

          # Builds an {Enum} and registers the constructor with the {.container}
          #
          # @param see (Enum.new)
          #
          # @example
          #   Types['enum.users.types'][:admin] # => <Enum::Value admin=3>
          #
          # @raise [Dry::Container::Error] if existing key
          #
          # @return [Dry::Types::Constructor]
          def Enum(*args, **options, &block) # rubocop:disable MethodName
            enum = Enum.new(*args, constructor: :set, **options, &block)

            constructor = container['integer'].constructor(&enum.method(:[]))
            container.register(enum.key, constructor, call: false)
            enum
          end

        end

        # :nodoc
        module InstanceMethods

          # @return [Proc] The `Dry::Types` constructor
          def type; Types.container[key]; end

        end

      end

    end

  end

end
