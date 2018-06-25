# frozen_string_literal: true

require 'spec_helper'
require 'dry/container'
require 'dry/container/stub'
require 'piktur/spec/helpers/container'
require 'piktur/support/enum'
require 'piktur/support/types'

module Piktur
  module Support

    RSpec.describe Types do
      it_should_behave_like 'a container', Types.container

      Spec::Helpers::Container.containerize(Types, stub: true)

      describe '.Model(key, constructor)' do
        include_context 'stub container', Types

        before(:all) do
          ::Model = ::Class.new do
            def self.name
              'HisDisgust'
            end

            def self.call(params)
              new(params)
            end
          end
        end

        let(:key)         { Inflector.underscore(Model.name) }
        let(:constructor) { Model.method(:call).to_proc }
        let(:result)      { Types.container[key] }

        describe 'the constructor' do
          before do
            Types.Model(key, constructor)
          end

          it 'is assigned to the Types container' do
            expect(result).to be_a(::Proc)
          end
        end
      end

      describe '.Enum(name, namespace, options, &block)' do
        include_context 'stub container', Types

        let(:options)   { ::Hash[predicates: nil, scopes: nil, i18n_scope: nil] }
        let(:name)      { :colours }
        let(:namespace) { ::Test.safe_const_reset(:Palette, ::Module.new) }
        let(:key)       { 'enum.test.palette.colours' }

        let(:block) do
          lambda do
            default :black
            value   :blue
            value   :purple
            value   :red
          end
        end

        before do
          Types.Enum(namespace, name, options, &block)
        end

        let(:result) { Types.container[key] }

        describe 'the constructor' do
          it 'is assigned to the Types container' do
            expect(result).to be_a(Proc)
            expect(result[:black]).to be_a(Enum::Value).or(raise_error)
          end
        end

      end
    end

  end
end