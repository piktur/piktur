# frozen_string_literal: true

require 'spec_helper'
require 'piktur/setup/loader/strategies/filters/matcher'

RSpec.describe Piktur::Loader::Matcher do
  separator = ::File::SEPARATOR

  let(:singular) { 'model' }
  let(:plural) { 'models' }

  describe '.call(*args, glob:, path:)' do
    context 'when glob false' do
      let(:result) { described_class.call('models') }

      it 'should return a regex' do
        expect(result).to be_a(Regexp)
      end
    end

    context 'when glob true' do
      let(:result) { described_class.call('repositories', glob: true) }

      it 'should return a set of glob patterns' do
        expect(result).to be_a(String)
      end
    end
  end

  # intersection = insersect(a, b)
  # parts = ["[\/\.]"]
  # if a != b
  #   range = (intersection.size - 1)..-1
  #   parts.insert(0, intersection.chop)
  #   parts.insert(1, "(#{a[range]}|#{b[range]})")
  # else
  #   parts.insert(0, intersection)
  # end
  describe 'Regexp' do
    let(:matcher) { described_class::Regexp[singular, plural] }

    shared_examples 'it should match' do
      it 'should match' do
        expect(separator + singular + separator).to match(matcher)
        expect(separator + plural + separator).to match(matcher)
      end
    end

    describe '.[]' do
      context 'when plural contains all of singular' do
        let(:singular) { 'model' }
        let(:plural) { 'models' }

        include_examples 'it should match'

        it { expect('/model.rb').to match(matcher) }

        it { expect('/modela.rb').not_to match(matcher) }
      end

      context 'when plural does not contain all of singular' do
        let(:singular) { 'repository' }
        let(:plural) { 'repositories' }

        include_examples 'it should match'

        it { expect('/repository.rb').to match(matcher) }

        it { expect('/repositori/').not_to match(matcher) }
      end

      context 'when uncountable' do
        let(:singular) { '/sheep/' }
        let(:plural) { singular }

        include_examples 'it should match'
      end
    end

    describe '.combine(arr)' do
      let(:matcher) { described_class.combine(['models', 'repositories']) }

      let(:singular) { 'model' }
      let(:plural) { 'models' }

      include_examples 'it should match'

      it { expect('/model.rb').to match(matcher) }

      it { expect('/models').to match(matcher) }

      it { expect('/modela.rb').not_to match(matcher) }
    end
  end

  describe 'Glob' do
    let(:glob) { described_class::Glob[singular, plural] }
    let(:singular) { 'repository' }
    let(:plural) { 'repositories' }

    it 'should return a glob pattern including the component type' do
      expect(glob).to end_with('repositor{*,**/*}.rb')
    end

    describe '.combine(arr)' do
      let(:globs) { described_class.combine(['models', 'repositories'], glob: true) }

      it { expect(globs).to all(be_a(String)) }
    end
  end
end
