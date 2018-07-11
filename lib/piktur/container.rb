# frozen_string_literal: true

require 'dry/container'

module Piktur

  class Container

    include ::Dry::Container::Mixin
    include Support::Container::Mixin

    # @return [void]
    def finalize!; end

  end

end
