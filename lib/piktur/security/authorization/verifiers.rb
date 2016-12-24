# frozen_string_literal: true

module Piktur

  module Security

    module Authorization

      # @todo Ensure users can NOT change {User#role} via request parameters. Add to strong
      #   parameters filter.
      #
      # Helper methods utilised within Controllers [`Piktur::Api::V1::ApplicationController`] and
      # Policies [{ApplicationPolicy}]. Methods MUST check expected `type` and {User#role}.
      module Verifiers

        extend  ActiveSupport::Concern
        include Roles

        # ClassMethods
        module ClassMethods; include Roles; end

        private

          # @return [Boolean]
          # def authenticated?
          #   entity.present?
          # end

          # Confirm entity provides **admin** criteria
          #
          # - entity: {Admin}
          # - criteria: {ROLES}[3]
          # - policy: {AdminPolicy}
          #
          # @return [Boolean]
          def admin?
            entity && entity.is_a?(::Admin) && entity.role == admin
          end

          # @!group Subscriber

          # Confirm entity provides **subscriber** criteria
          #
          # - entity: {Subscriber}
          # - criteria: {ROLES}(0..2)
          # - policy: {SubscriberPolicy}
          #
          # @return [Boolean]
          def subscriber?
            entity && entity.is_a?(::Subscriber) && entity.role.in?(subscribers)
          end

          # Confirm entity provides **subscriber (basic)** criteria
          #
          # - entity: {Subscriber}
          # - criteria: {ROLES}[0]
          # - policy: {Plan::BasicPolicy}
          #
          # @return [Boolean]
          def basic?
            entity && entity.role == subscriber_basic
          end
          alias subscriber_basic? basic?

          # Confirm entity provides **subscriber (standard)** criteria
          #
          # - entity: {Subscriber}
          # - criteria: {ROLES}[1]
          # - policy: {Plan::StandardPolicy}
          #
          # @return [Boolean]
          def standard?
            entity && entity.role == subscriber_standard
          end
          alias subscriber_standard? standard?

          # Confirm entity provides **subscriber (complete)** criteria
          #
          # - entity: {Subscriber}
          # - criteria: {ROLES}[2]
          # - plan: {Plan::CompletePolicy}
          #
          # @return [Boolean]
          def complete?
            entity && entity.role == subscriber_complete
          end
          alias subscriber_complete? complete?

          # Entity SHOULD be **readonly** when requested via public route ie. `/api/v1/client/*`
          #
          # {include:#subscriber?}
          #
          # @return [Boolean]
          def visitor?
            subscriber? && entity.readonly?
          end

          # @!endgroup

          # Confirm entity provides **customer** criteria
          #
          # - entity: {Store::Customer}
          # - criteria: {ROLES}[4]
          # - plan: {CustomerPolicy}
          #
          # @todo piktur_store/app/models/store/customer is incomplete.
          #
          # @return [Boolean]
          def customer?
            entity.is_a?(::Store::Customer) && entity.role == customer
          end

      end

    end

  end

end
