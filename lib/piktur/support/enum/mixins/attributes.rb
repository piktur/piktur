# frozen_string_literal: true

module Piktur::Support # rubocop:disable ClassAndModuleChildren

  module Enum

    # Builds a Module containing methods named after the given `attribute`:
    #   * `default_<attribute>!`
    # And methods per enumerated value:
    #   * `<attribute>!` Sets the attribute to the named value
    #
    # @example
    #   class Model
    #     ::NAMESPACE::Types.Enum(
    #       self,
    #       :syntaxes,
    #       attributes: 'syntax',
    #       markdown: { value: 0, default: true },
    #       html: { value: 1 }
    #     )
    #     ::ApplicationModel[self, :Base, %w(syntax)]
    #   end
    #
    #   obj = Model.new
    #
    #   obj.default_syntax!   # Set default value for attribute
    #   obj.syntax            # => 0
    #
    #   obj.html!
    #   obj.syntax            # => 1
    #   obj.html?             # => true
    Attributes = lambda do |attribute, enum|
      ::Module.new do
        setter = "#{attribute}=".to_sym

        define_method("default_#{attribute}!".to_sym) { send(setter, enum.default_value) }

        enum.each do |obj|
          define_method("#{obj.key}!".to_sym) { send(setter, obj.value) }
        end
      end
    end

  end

end
