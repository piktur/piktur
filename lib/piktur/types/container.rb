# frozen_string_literal: true

class Piktur::Types::Container < Piktur::Container::Base # rubocop:disable ClassAndModuleChildren, Documentation

  def self.new(*)
    super.tap do |container|
      container.merge(::Dry::Types.container)
    end
  end

end
