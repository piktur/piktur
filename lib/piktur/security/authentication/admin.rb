# frozen_string_literal: true
# rubocop:disable Rails/DynamicFindBy

module Piktur

  module Security

    module Authentication

      # Authentication logic for {Admin}
      module Admin

        # @param [Class, Module] base
        # @return [void]
        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
        end

        # ClassMethods
        module ClassMethods

          # Override User::ClassMethods

        end

        # InstanceMethods
        module InstanceMethods

          # Override User::InstanceMethods

        end

      end

    end

  end

end
