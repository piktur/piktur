# frozen_string_literal: true

require 'spec_helper'

RSpec.require_support 'env', app: 'piktur'

RSpec.describe Piktur do
  let(:object) do
    __binding__ = Object.new
    def __binding__.pry; end
    __binding__
  end
  let(:diff) { 1 }
  let(:options) { {} }
  let(:debugger) { File.expand_path('../lib/piktur/debugger.rb', __dir__) }

  it('should respond to .debug') { should respond_to(:debug) }

  shared_context 'call' do
    after { Piktur.debug(object, diff, **options) }
  end

  shared_examples 'logger' do
    context 'if warning given' do
      after { Piktur.debug(object, diff, warning: 'msg', **options) }

      it 'should log warning' do
        expect(Piktur.logger).to receive(:warn).with('msg')
      end
    end
  end

  shared_examples 'exception' do
    context 'if error given' do
      after { Piktur.debug(object, diff, error: 'msg', **options) }

      it 'should log error' do
        expect(Piktur.logger).to receive(:error).with('msg')
      end
    end

    context 'if raise' do
      it 'should raise error' do
        expect { Piktur.debug(object, diff, raise: StandardError) }.to raise_error
      end
    end
  end

  shared_examples 'enabled' do
    include_context 'call'

    it 'should open a debugging session' do
      expect(object).to receive(:pry).at_least(:once)
    end
  end

  shared_examples 'disabled' do
    include_context 'call'

    it 'should NOT open a debugging session' do
      expect(object).not_to receive(:pry)
    end
  end

  describe '.debug(object, diff, warning: nil, error: nil)' do
    context 'when actual behaviour matches expectations' do
      let(:diff) { false }

      include_examples 'disabled'
    end

    context 'when IN production mode' do
      include_context 'env', 'production'

      before do
        allow(Piktur.const_get(:DEBUGGER)).to receive(:call).and_return(nil)

        Piktur.safe_remove_const(:DEBUGGER)
        load debugger
      end

      include_examples 'disabled'

      include_examples 'logger'

      include_examples 'exception'
    end

    context 'when NOT IN debug mode' do
      before(:all) { ENV.delete('DEBUG') }

      include_context 'call'

      include_examples 'disabled'

      include_examples 'logger'

      it 'should suppress exceptions' do
        expect(Piktur).to receive(:debug).at_least(:once)
          .with(object, diff, **options)
          .and_return(nil)
      end
    end

    context 'when IN debug mode' do
      before(:all) { ENV['DEBUG'] = '1' }

      before do
        Piktur.safe_remove_const(:DEBUGGER)
        load debugger

        allow(object).to receive(:pry).and_return(nil) # Mock pry session
      end

      context 'when behaviour IS NOT expected AND a debugger entry point is set' do
        include_examples 'enabled'
      end

      include_examples 'logger'

      context 'if error given' do
        let(:options) { { error: 'msg' } }

        include_context 'call'

        it 'should log error' do
          expect(Piktur.logger).to receive(:error).with('msg')
        end
      end

      context 'if raise given' do
        it 'should raise error' do
          expect { Piktur.debug(object, diff, raise: StandardError) }.to raise_error
        end
      end
    end
  end
end
