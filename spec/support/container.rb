# frozen_string_literal: true

module Piktur::Spec::Helpers::Container
  %i(transactions operations).each { |aliaz| alias_method aliaz, :container }

  def types(namespace: ::Piktur::Types, &block)
    container(__callee__, namespace: namespace, &block)
  end
end

RSpec.shared_context 'container' do
  include Piktur::Spec::Helpers::Container

  let(:test_container) do
    stub_const('Test::Container', ::Class.new {
      include ::Dry::Container::Mixin
      include ::Piktur::Support::Container::Mixin

      def self.new(*); super.tap { |container| container.enable_stubs! }; end
    })
  end
end

RSpec.shared_examples 'a container' do
  describe '.container' do
    it { should respond_to(:[]) }

    it { should respond_to(:register) }

    it { should respond_to(:resolve) }

    it { should respond_to(:namespace) }

    it { should be_a(::Dry::Container::Mixin) }
  end
end
