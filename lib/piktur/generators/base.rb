# frozen_string_literal: true

module Piktur

  module Generators

    # Modify `Rails::Generators::Base` methods to suit `Piktur::Generators`
    module ClassMethods

      # Returns the base root for a common set of generators. This is used to dynamically
      # guess the default source root.
      def base_root
        __dir__
      end

    end

    # @example Create a new Base class under Piktur::Generators
    class Base < Rails::Generators::Base

      extend ClassMethods

    end

  end

end
