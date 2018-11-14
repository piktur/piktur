# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Piktur::Container, 'container naming' do
  let(:container) { Container.new }

  before do
    stub_const('Container', Class.new(Piktur::Container::Base))
  end

  describe '#to_key(input)' do
    let(:expected) { 'namespace.item' }

    shared_examples 'container key' do
      let(:result) { container.to_key(input) }

      it('should replace word breaks with the container separator') do
        expect(result).to eq(expected)
      end
    end

    context 'when string' do
      context 'contains :' do
        let(:input) { 'Namespace::Item' }

        include_examples 'container key'
      end

      context 'contains /' do
        let(:input) { 'namespace/item' }

        include_examples 'container key'
      end

      context 'mixed case' do
        let(:input) { 'namespace.ITEM' }

        include_examples 'container key'
      end

      context 'contains \s' do
        let(:input) { 'namespace item' }

        include_examples 'container key'
      end
    end

    context 'when array' do
      context 'of strings' do
        let(:input) { %w(namespace item) }

        include_examples 'container key'
      end

      context 'of symbols' do
        let(:input) { [:Namespace, :item] }

        include_examples 'container key'
      end

      context 'of mixed type' do
        before { stub_const('Namespace', Module.new)  }

        let(:input) { [Namespace, :item] }

        include_examples 'container key'
      end
    end

    context 'when module' do
      before { stub_const('Namespace::Namespace::Item', Module.new)  }

      let(:input) { Namespace::Namespace::Item }
      let(:expected) { 'namespace.namespace.item' }

      include_examples 'container key'
    end
  end
end
