# frozen_string_literal: true

require 'spec_helper'

RSpec.require_support 'container', app: 'piktur'

module Piktur
  module Support

    RSpec.describe Types do
      include_context 'container'
      it_should_behave_like 'a container'

      subject { Types.container }

      describe '.Model(key, constructor)' do
        before(:all) do
          ::Test.safe_const_reset(:Model, ::Class.new {
            attr_reader :attributes
            def self.call(params); new(params); end
            def initialize(input); @attribues = input; end
          })
        end

        after(:all) { ::Test.safe_remove_const(:Model) }

        before do
          reset_container!(:container, namespace: Types, stub: false)
          Types.Model(key, ::Test::Model)
        end

        let(:key) { Inflector.underscore(::Test::Model.name) }
        let(:result) { Types.container[key] }

        describe 'the constructor' do
          it 'is assigned to the Types container' do
            expect(result).to be_a(::Dry::Types::Type)
          end

          it 'builds a new class' do
            expect(result.call(blackened: :sheath))
          end
        end
      end

      describe '.Enum(name, namespace, options, &block)' do
        before do
          reset_container!(:container, namespace: Types, stub: false)

          Types.Enum(name, namespace: namespace, **options) do
            default :black
            value   :blue
            value   :purple
            value   :red
          end
        end

        let(:options) { ::Hash[predicates: nil, i18n_scope: nil] }
        let(:name) { :colours }
        let(:namespace) { ::Test.safe_const_reset(:Palette, ::Module.new) }
        let(:key) { 'enum.test.palette.colours' }
        let(:result) { Types.container[key] }

        describe 'the constructor' do
          it 'is assigned to the Types container' do
            expect(result).to be_a(::Dry::Types::Type)
          end

          it 'casts input to enum value' do
            expect(result[:black]).to be_a(Enum::Value).or(raise_error)
          end
        end

      end
    end

  end
end
