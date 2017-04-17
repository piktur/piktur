# frozen_string_literal: true

module Piktur

  module Security

    # ## Authorization (based on `pundit`)
    #
    # Permissions assigned according to {User::Base#role}. Authorization performed against
    # {ApplicationPolicy}.
    #
    # Resource ownership tracked via {Account::Ownership}
    #
    # @todo [#19](https://bitbucket.org/piktur/piktur_core/issues/19/checking-financial-state-of)
    #
    module Authorization

      # Return human readable role descriptors
      # @note {User::Base#role} stores an `Integer` corresponding to entry's position within
      #   {ROLES}
      # @see Roles
      # @return [Array]
      ROLES = [ # rubocop:disable Style/MutableConstant
        'piktur_basic',    # 0
        'piktur_standard', # 1
        'piktur_complete', # 2
        'admin',           # 3
        'customer'         # 4
      ]

      # Return friendly role descriptor
      # @param [String, Fixnum] val
      #
      # @example
      #   Piktur::Security::Authorization.find_role('admin')
      #   # => 3
      #
      #   Piktur::Security::Authorization.find_role(3)
      #   # => 'admin'
      #
      # @return [Fixnum] if `String` given, returns **index** of value
      # @return [String] if `Fixnum` given, returns **value** at index
      def ROLES.find_role(val)
        if val.is_a?(String)
          find_index(val)
        elsif val.is_a?(Integer)
          self[val]
        end
      end

      # Returns possible {User::Subscriber} roles as a `Range`
      # @see file:spec/benchmark/array.rb Collect indices
      # @example
      #   return @subscribers if @subscribers
      #   roles = []
      #   ::Piktur::Security::Authorization::ROLES.each.with_index do |e, i|
      #     roles << i if e =~ /basic|standard|complete/
      #   end
      #   @subscribers = (roles[0]..roles[-1])
      # @return [Range]
      def ROLES.subscribers
        (0..2)
      end

      ROLES.freeze

      extend ActiveSupport::Autoload

      eager_autoload do
        autoload :Roles
        autoload :Verifiers
        autoload :Authorizable
      end

      extend Roles

    end

  end

end
