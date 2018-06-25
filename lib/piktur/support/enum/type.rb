# frozen_string_literal: true

module Piktur

  module Support

    class Enum

      # @see Types
      module Type

        # @return [Proc] The registered type caster
        def type; ::Piktur::Support::Types[key]; end

        # @!attribute [r] key
        #   @return [String]
        def key
          @key ||= ::Piktur::Support::Container.Key(i18n_scope).freeze
        end

      end

    end

  end

end
