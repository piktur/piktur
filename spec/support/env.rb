# frozen_string_literal: true

RSpec.shared_context 'env' do |env|
  let(:__env__) { String.new(env) }

  prepend_before do
    case __env__
    when 'development'
      def __env__.production?; false; end
      def __env__.development?; true; end
      def __env__.test?; true; end
    when 'production'
      def __env__.production?; true; end
      def __env__.development?; false; end
      def __env__.test?; true; end
    end

    allow(Rails).to receive(:env).and_return(__env__) if defined?(Rails)
    allow(Piktur).to receive(:env).and_return(__env__) if defined?(Piktur)
  end
end
