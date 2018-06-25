# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/piktur/support/file_matcher.rb'

module Piktur
  module Support
    RSpec.describe FileMatcher do
      separator = ::File::SEPARATOR

      let(:singular) { 'model' }
      let(:pluralar) { 'models' }

      describe '.call(*args, glob:, path:)' do

        context 'when glob false' do
          let(:result) { described_class.call('models', 'repositories') }

          it 'should return a set of regex' do
            result.each { |e| expect(e).to be_a(Regexp) }
          end
        end

        context 'when glob true' do
          let(:result) { described_class.call('models', 'repositories', glob: true) }

          it 'should return a set of glob patterns' do
            result.each { |e| expect(e).to be_a(String) }
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
      describe '.to_regex' do
        let(:matcher) { described_class.to_regex(singular, pluralar) }

        shared_examples 'it should match' do
          it 'should match' do
            expect(separator + singular + separator).to match(matcher)
            expect(separator + pluralar + separator).to match(matcher)
          end
        end

        context 'when plural contains all of singular' do
          let(:singular) { 'model' }
          let(:pluralar) { 'models' }

          include_examples 'it should match'

          it { expect('/model.rb').to match(matcher) }

          it { expect('/modela.rb').not_to match(matcher) }
        end

        context 'when plural does not contain all of singular' do
          let(:singular) { 'repository' }
          let(:pluralar) { 'repositories' }

          include_examples 'it should match'

          it { expect('/repository.rb').to match(matcher) }

          it { expect('/repositori/').not_to match(matcher) }
        end

        context 'when uncountable' do
          let(:singular) { '/sheep/' }
          let(:pluralar) { singular }

          include_examples 'it should match'
        end
      end

      describe '#to_glob' do
        let(:glob) { described_class.to_glob(singular, pluralar) }
        let(:singular) { 'repository' }
        let(:pluralar) { 'repositories' }

        it 'should return a glob pattern including the component type' do
          expect(glob).to end_with('repositor{*,**/*}.rb')
        end
      end
    end
  end
end
