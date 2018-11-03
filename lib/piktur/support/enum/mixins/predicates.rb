# frozen_string_literal: true

module Piktur::Support # rubocop:disable ClassAndModuleChildren

  module Enum

    # Builds a Module containing methods named after the given `attribute`:
    #   * `default_<attribute>!`
    # And methods per enumerated value:
    #   * `<attribute>?` Checks value equality
    #
    # @example
    #   class Model
    #     ::NAMESPACE::Types.Enum(
    #       self,
    #       :syntaxes,
    #       predicates: 'syntax',
    #       attributes: 'syntax',
    #       markdown: { value: 0, default: true },
    #       html: { value: 1 }
    #     )
    #     ::ApplicationModel[self, :Base, %w(syntax)]
    #   end
    #
    #   obj = Model.new
    #
    #   obj.syntax    # => 0
    #   obj.markdown? # => true
    #
    #   obj.syntax    # => 1
    #   obj.html?     # => true
    Predicates = lambda do |attribute, enum|
      ::Module.new do
        setter = "#{attribute}=".to_sym
        getter = attribute.to_sym

        define_method("default_#{attribute}!".to_sym) { send(setter, enum.default_value) }

        enum.each do |obj|
          define_method("#{obj.key}?".to_sym) { obj == send(getter) }
          define_method("#{obj.key}!".to_sym) { send(setter, obj.value) }
        end
      end
    end

  end

end
