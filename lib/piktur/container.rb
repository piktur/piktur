# frozen_string_literal: true

require 'dry/container'

module Piktur::Container # rubocop:disable ClassAndModuleChildren, Documentation

  extend ::ActiveSupport::Autoload

  autoload :Aggregate
  autoload :Base
  autoload :Delegates
  autoload :Key
  autoload :Mixin

end
