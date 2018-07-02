# frozen_string_literal: true

module Piktur

  module Loader

    # @todo
    #
    # @example Wrapper for ROM::AutoRegistration
    #   # Overload loading mechanism
    #   ROM::AutoRegistration.class_eval do
    #     def require(file)
    #       require_dependency(file)
    #     end
    #   end
    #
    #   loader = Piktur::Loader::Dry.new.instance_exec do
    #     self.target = Piktur.components_dir
    #     self.types  = Piktur::DB.config.component_dirs.values
    #   end
    #
    #   Piktur::DB.config.adapter.auto_registration(
    #     loader.target,
    #     namespace: 'Object',
    #     globs:     loader.patterns
    #   )
    class Dry

      include Base

      # @!group Pattern Matching

      # @see Filters#patterns
      def patterns
        @patterns ||=
          ::Hash[types.map { |t| [t, Matcher.call(t, glob: true, path: target)] }].freeze
      end

      # @!endgroup

    end

  end

end
