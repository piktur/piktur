# frozen_string_literal: true

module Piktur

  module Security

    # @abstract
    #
    # BasePolicy is an abstract class. Subclass must redefine `#authorized?` to clarify
    # authorization ruling.
    #
    # @!attribute entity
    #   @return [User::Base]
    # @!attribute object
    #   @example
    #     @object ||= (n = self.class.to_s)[n.rindex('::') + 2..-7].to_sym
    #   @return [Symbol]
    #
    class BasePolicy

      include ::Piktur::Security::Authorization::Verifiers

      attr_accessor :entity, :object

      # @param [User::Base] entity
      # @param [Class, ActiveRecord::Relation, ActiveRecord::Base, Array] object
      def initialize(entity, object)
        @entity = entity
        @object = object
      end

      # @raise [NotImplementedError]
      # @return [void]
      def authorized?
        raise NotImplementedError, <<~EOS
          BasePolicy is an abstract class. You must redefine `#authorized?`
          within subclass to clarify authorization ruling.
        EOS
      end

    end

  end

end
