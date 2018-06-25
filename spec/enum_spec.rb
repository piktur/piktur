# frozen_string_literal: true

require 'spec_helper'

require_relative APP_ROOT.join('lib/piktur/support/enum.rb')

module Piktur::Support
  # context 'when block given to finalize' do
  #   it 'should add the methods to the enum instance' do
  #     expect(Piktur['enum.test.users.types']).to be_extended
  #   end
  # end

  RSpec.describe Enum do
    let(:options)   { ::Hash[predicates: nil, scopes: nil, i18n_scope: nil] }
    let(:name)      { :colours }
    let(:namespace) { ::Test.safe_const_reset(:Palette, ::Module.new) }
    let(:block) do
      lambda do
        default :black
        value   :blue
        value   :purple
        value   :red

        finalize do |enum|
          def enum.extended?; true; end
        end
      end
    end

    subject(:enum) { Enum.new(namespace, name, options, &block) }

    describe '.new(namespace, name, options, &block)' do
      it 'should map enumerable values' do
        expect(enum[:black]).to   eq(0)
        expect(enum[:black]).to   eq(enum.default)
        expect(enum[:blue]).to    eq(1)
        expect(enum[:purple]).to  eq(2)
        expect(enum[:red]).to     eq(3)

        expect(enum).to be_extended
      end

      context 'with an attribute name' do
        it 'should build predicate methods for the attribute'
      end

      context 'with scoped attribute' do
        it 'should build scopes for the attribute'
      end

      context 'when value(s) not numeric' do
        it 'should raise NonNumericValueError'
      end

      context 'with duplicate key' do
        it 'should raise ArgumentError'
      end

      context 'with duplicate value' do
        it 'should raise ArgumentError'
      end
    end

    describe '#initialize(collection, i18n_scope:, *enumerable, &block)' do
    end

    describe '#find' do
      it 'should return value corresponding to input'

      context 'when input is not in enumerable' do
        it 'should return default'
      end
    end

    describe '#find!' do
      it 'should return value corresponding to input'

      context 'when input is not in enumerable' do
        it 'should raise error'
      end
    end

    describe '#each(&block)' do
      it 'should yield values to block'
    end

    describe '#select(&block)' do
      it 'should yield values to block and return Values matching conditions'
    end

    describe '#values_at(keys)' do
      it 'should return Value for each key'
    end

    describe '#to_s' do
      it 'should return humanized collection name'
    end

    describe '#to_enum' do
      it 'should return Enumerator'
    end

    describe '#call(input)' do
      it 'should return Value matching key or value'

      context 'when input is not in enumerable' do
        it 'should return default if set'
      end
    end

    describe '#type' do
      it 'should return Dry::Types::Constructor'
    end

    describe '#find_by_key' do
      it 'should return Value matching key'
    end

    describe '#find_by_value' do
      it 'should return Value matching value'
    end

    describe '#find_by_key!(key)' do
      it 'should return Value matching key'

      context 'when input is not in enumerable' do
        it 'should raise error'
      end
    end

    describe '#find_by_value!(value)' do
      it 'should return Value matching value'

      context 'when input is not in enumerable' do
        it 'should raise error'
      end
    end

    describe '#include?(value)' do
      it 'should return Boolean'
    end

    describe '#default_value' do
      it 'sould return the default value if default set'
    end

    describe '#size' do
      it 'should return the number of enumerable values'
    end

    describe '#to_hash' do
      it 'should return mapping'
    end

    describe '#to_h' do
      it 'should return mapping'
    end

    describe '#to_a' do
      it 'should return enumerable values'
    end

    describe '#predicates(attribute)' do
      it 'should return a Module'
    end

    describe '#scopes(attribute)' do
      it 'should return a Module'
    end

    describe Enum::Value do
      describe '#meta' do
        it 'should return a Hash'
      end

      describe '#matcher' do
        it 'should return a Regexp'
      end

      describe '#key' do
        it 'should return a Symbol'
      end

      describe '#value' do
        it 'should return an Integer'
      end

      describe '#i18n_scope' do
        it 'should return an Array including enum and module namespace, and collection name'
      end

      describe '#as_json(**)' do
        it 'should return an Integer'
      end

      describe '#human' do
        it 'should return translated String'
      end

      describe '#to_s' do
        it 'should return a String'
      end

      describe '#to_i' do
        it 'should return an Integer'
      end

      describe '#default?' do
        it 'should return Boolean'
      end

      describe '#eql?(other)' do
        it 'should return Boolean if value or key match other'
      end

      describe '#==(other)' do
        described_class.instance_method(:=~).original_name == :eql?
      end

      describe '#===(other)' do
        it 'should return Boolean'
      end

      describe '#match?(other)' do
        it 'should return Boolean'
      end

      describe '#=~(other)' do
        described_class.instance_method(:=~).original_name == :match?
      end
    end
  end
end